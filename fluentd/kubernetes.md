## fluend conf example
### Collect from Docker socket
```xml
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

### Concat
Ref: https://github.com/fluent-plugins-nursery/fluent-plugin-concat

```xml
# concat log split by docker log driver (ref. https://bugzilla.redhat.com/show_bug.cgi?id=1573680
<filter kubernetes.**>
  @type concat
  key log
  multiline_end_regexp /\n$/
</filter>
```

### Parser
Ref: https://docs.fluentd.org/parser

```xml
<filter kubernetes.**>
  @type parser
  format json
  key_name log
  hash_value_field parsed
  reserve_data true
  # ignore parse error caused by non json format log
  emit_invalid_record_to_error true
  time_key nil
</filter>

<label @ERROR>
  # just discard this time
  <match **>
    type null
  </match>
</label>
```

### Record Transformer
Ref: https://docs.fluentd.org/filter/record_transformer

embed s3 dest info
```xml
<filter kubernetes.**>
  @type record_transformer
  enable_ruby true

  <record>
    metadata ${"#{ENV['S3_ROOT']}" + "." + record["kubernetes"]["namespace_name"] + "." + record["kubernetes"]["pod_name"] + "." + record["kubernetes"]["container_name"]}
  </record>
</filter>
```

### Rewrite Tag
Ref: https://github.com/fluent/fluent-plugin-rewrite-tag-filter

```xml
# tag transform
# original_tag: kubernetes.var.log.containers.<pod_name>_<namespace>_<filename>.log
# after_tag:    rewritten.<s3_root>.<namespace>.<pod_name>.<container_name>
<match kubernetes.**>
  @type rewrite_tag_filter

  <rule>
    key metadata
    pattern ^(.+)$
    tag rewritten.$1
  </rule>
</match>
```

### Copy and Relabel
Ref:
* https://docs.fluentd.org/output/copy
* https://docs.fluentd.org/output/relabel

```xml
<match rewritten.**>
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

### S3 Out
Ref: https://docs.fluentd.org/output/s3

```xml
<label @application_logs>
  # tag transform
  # original_tag: rewritten.<s3_root>.<namespace>.<pod_name>.<container_name>
  # after_tag:    categorized.<s3_root>.<namespace>.<pod_name>.<container_name>.<log_type>
  <match rewritten.**>
    @type rewrite_tag_filter

    <rule>
      key log
      pattern \"tag\":\"(\w+)\"
      tag categorized.${tag_parts[1]}.${tag_parts[2]}.${tag_parts[3]}.${tag_parts[4]}.$1
    </rule>
  </match>

  # tag: categorized.<s3_root>.<namespace>.<pod_name>.<container_name>.<log_type>
  <match categorized.**>
    @type s3
    @id out_apps_s3
    @log_level info
    s3_region ap-northeast-1
    s3_bucket "#{ENV['S3_BUCKET_NAME']}"
    s3_object_key_format %{path}%{time_slice}_${tag[3]}_${tag[4]}_%{index}.%{file_extension}
    path ${tag[1]}/application_logs/${tag[2]}/${tag[5]}/
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
  # tag: rewritten.<s3_root>.<namespace>.<pod_name>.<container_name>
  <match rewritten.**>
    @type s3
    @id out_container_s3
    @log_level info
    s3_region ap-northeast-1
    s3_bucket "#{ENV['S3_BUCKET_NAME']}"
    s3_object_key_format %{path}%{time_slice}_${tag[3]}_%{index}.%{file_extension}
    path ${tag[1]}/container_logs/${tag[2]}/${tag[4]}/
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
      path /var/log/fluentd-buffers/container_s3.buffer
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

