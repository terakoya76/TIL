## Collect from Docker socket
```
@include "#{ENV['FLUENTD_SYSTEMD_CONF'] || 'systemd'}.conf"
@include "#{ENV['FLUENTD_PROMETHEUS_CONF'] || 'prometheus'}.conf"
@include kubernetes.conf
@include conf.d/*.conf
<system>
  @log_level info
  <log>
    format json
  </log>
</system>

<source>
  @type forward
  @log_level info
</source>
```

## Concat
- https://github.com/fluent-plugins-nursery/fluent-plugin-concat
```
# concat log split by docker log driver (ref. https://bugzilla.redhat.com/show_bug.cgi?id=1573680
<filter kubernetes.**>
  @type concat
  key log
  multiline_end_regexp /\n$/
</filter>
```

## Parser
- https://docs.fluentd.org/parser
```
<filter kubernetes.**>
  @type parser
  format json
  key_name log
  hash_value_field parsed
  reserve_data true
  # ignore parse error caused by non json format log
  emit_invalid_record_to_error false
  time_key nil
</filter>
```

## Record Transformer
- https://docs.fluentd.org/filter/record_transformer
```
<filter kubernetes.**>
  @type record_transformer
  enable_ruby true
  <record>
    s3_root ${"#{ENV['S3_ROOT']}"}
  </record>
</filter>
```

## Rewrite Tag
- https://github.com/fluent/fluent-plugin-rewrite-tag-filter
```
# original_tag: kubernetes.var.log.containers.<pod_name>_<namespace>_<filename>.log
# after_tag:    s3_root_attached.<s3_root>.kubernetes.var.log.containers.<pod_name>_<namespace>_<filename>.log
<match kubernetes.**>
  @type rewrite_tag_filter
  <rule>
    key $['s3_root']
    pattern ^(.+)$
    tag s3_root_attached.$1.${tag}
  </rule>
</match>
```

## Copy and Relabel
- https://docs.fluentd.org/output/copy
- https://docs.fluentd.org/output/relabel
```
<match s3_root_attached.**>
  @type copy
  <store>
    @type relabel
    @label @application_logs
  </store>
  <store>
    @type relabel
    @label @container_logs
  </store>
</match>
```

## S3 Out
- https://docs.fluentd.org/output/s3
```
<label @application_logs>
  # create temporary metadata for tag
  <filter s3_root_attached.**>
    @type record_transformer
    enable_ruby true
    <record>
      namespace_name ${record["kubernetes"]["namespace_name"]}
    </record>
  </filter>

  # tag transform
  # original_tag: s3_root_attached.<s3_root>.kubernetes.var.log.containers.<pod_name>_<namespace>_<filename>.log
  # after_tag:    namespace_attached.<s3_root>.application_logs.<namespace>
  <match s3_root_attached.**>
    @type rewrite_tag_filter
    <rule>
      key namespace_name
      pattern ^(.+)$
      tag namespace_attached.${tag_parts[1]}.application_logs.$1
    </rule>
  </match>

  # tag transform
  # original_tag: namespace_attached.<s3_root>.application_logs.<namespace>
  # after_tag:    categorized.<s3_root>.application_logs.<namespace>.<log_type>
  <match namespace_attached.**>
    @type rewrite_tag_filter
    <rule>
      key log
      pattern \"tag\":\"(\w+)\"
      tag categorized.${tag_parts[1]}.${tag_parts[2]}.${tag_parts[3]}.$1
    </rule>
  </match>

  <match categorized.**>
    @type s3
    @id out_apps_s3
    @log_level info
    s3_region ap-northeast-1
    s3_bucket "#{ENV['S3_BUCKET_NAME']}"
    s3_object_key_format %{path}%{time_slice}_${tag[4]}_%{index}.%{file_extension}
    path ${tag[1]}/${tag[2]}/${tag[3]}/${tag[4]}/
    time_slice_format     %Y/%m/%d/%H
    flush_interval        1m
    slow_flush_log_threshold 25s
    <inject>
      time_key time
      tag_key tag
      localtime false
    </inject>
    <buffer tag,time>
      @type file
      path /var/log/fluentd-buffers/apps_s3.buffer
      timekey 3600
      timekey_use_utc true
      chunk_limit_size 100m
    </buffer>
    <format>
      @type json
    </format>
  </match>
</label>

<label @container_logs>
  # create temporary metadata for tag
  <filter s3_root_attached.**>
    @type record_transformer
    enable_ruby true
    <record>
      s3_log_path ${"#{ENV['S3_ROOT']}" + ".container_logs." + record["kubernetes"]["namespace_name"] + "." + record["kubernetes"]["container_name"] + "." + record["kubernetes"]["pod_name"]}
    </record>
  </filter>

  # tag transform
  # original_tag: s3_root_attached.<s3_root>.kubernetes.var.log.containers.<pod_name>_<namespace>_<filename>.log
  # after_tag:    modified.<s3_root>.container_logs.<namespce>.<contaienr_name>.<pod_name>
  <match s3_root_attached.**>
    @type rewrite_tag_filter
    <rule>
      key $['s3_log_path']
      pattern ^(.+)$
      tag modified.$1
    </rule>
  </match>

  <match modified.**>
    @type s3
    @id out_s3
    @log_level info
    s3_region ap-northeast-1
    s3_bucket "#{ENV['S3_BUCKET_NAME']}"
    s3_object_key_format %{path}%{time_slice}_${tag[5]}_%{index}.%{file_extension}
    path ${tag[1]}/${tag[2]}/${tag[3]}/${tag[4]}/
    time_slice_format     %Y/%m/%d/%H
    flush_interval        1m
    slow_flush_log_threshold 25s
    <inject>
      time_key time
      tag_key tag
      localtime false
    </inject>
    <buffer tag,time>
      @type file
      path /var/log/fluentd-buffers/s3.buffer
      timekey 3600
      timekey_use_utc true
      chunk_limit_size 100m
    </buffer>
    <format>
      @type json
    </format>
  </match>
</label>
```
