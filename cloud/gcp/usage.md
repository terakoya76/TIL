# Usage on GCP

## Add configuration

```bash
filter=xxx
account=xxx
for proj in $(gcloud projects list | grep ${filter} | awk '{ print $1 }'); do
  gcloud config configurations create ${proj}
  gcloud config set project ${proj}
  gcloud config set account ${account}
done
```

## Cloudrun

### instance_count
api client
```ruby
require "google/cloud/monitoring"

project_id = ARGV[0]

client = Google::Cloud::Monitoring.metric_service
project_name = client.project_path project: project_id

now = Time.now
interval = Google::Cloud::Monitoring::V3::TimeInterval.new
interval.end_time = Google::Protobuf::Timestamp.new(seconds: now.to_i, nanos: now.nsec)
interval.start_time = Google::Protobuf::Timestamp.new(seconds: now.to_i - 60*60*24*7, nanos: now.nsec)
filter = 'metric.type="run.googleapis.com/container/instance_count"'
aggregation = Google::Cloud::Monitoring::V3::Aggregation.new(
  alignment_period:   { seconds: 60*60*24*7 },
  group_by_fields: ["resource.labels.service_name"],
  cross_series_reducer: Google::Cloud::Monitoring::V3::Aggregation::Reducer::REDUCE_MAX,
  per_series_aligner: Google::Cloud::Monitoring::V3::Aggregation::Aligner::ALIGN_MAX
)
view = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL

result = {}
data = client.list_time_series(
  name:     project_name,
  filter:   filter,
  interval: interval,
  view:     view
)
data.each do |ts|
  if ts.metric.labels["state"] == "active"
    val = ts.points.map(&:value).map(&:int64_value).max
    label = ts.resource.labels["service_name"]
    if result[label].nil?
      result[label] = val
    elsif result[label] < val
      result[label] = val
    end
  end
end

result.reduce([]) {|acc, (k, v)|
  acc << [project_id, k, v]
}.each {|l|
  p l.join(",")
}
```

executor
```bash
cat > Gemfile <<EOF
source "https://rubygems.org"

gem "google-cloud-monitoring"
EOF

bundle install

filter=xxx
log=result.csv

for proj in $(gcloud projects list | grep ${filter} | awk '{ print $1 }'); do
  bundle exec ruby check_cloudrun.rb ${proj} >> ${log}
done
```

### instance_count
api client
```ruby
require "google/cloud/monitoring"

project_id = ARGV[0]

client = Google::Cloud::Monitoring.metric_service
project_name = client.project_path project: project_id

now = Time.now
interval = Google::Cloud::Monitoring::V3::TimeInterval.new
interval.end_time = Google::Protobuf::Timestamp.new(seconds: now.to_i, nanos: now.nsec)
interval.start_time = Google::Protobuf::Timestamp.new(seconds: now.to_i - 60*60*24*7, nanos: now.nsec)
filter = 'metric.type="run.googleapis.com/request_count"'
aggregation = Google::Cloud::Monitoring::V3::Aggregation.new(
  alignment_period:   { seconds: 60*60*24*7 },
  group_by_fields: ["resource.labels.service_name"],
  per_series_aligner: Google::Cloud::Monitoring::V3::Aggregation::Aligner::ALIGN_SUM,
)
view = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL

result = {}
data = client.list_time_series(
  name:     project_name,
  filter:   filter,
  interval: interval,
  view:     view
)
data.each do |ts|
  label = ts.resource.labels["service_name"]
  val = ts.points.map(&:value).map(&:int64_value).sum

  if result[label].nil?
    result[label] = val
  else
    result[label] += val
  end
end

result.reduce([]) {|acc, (k, v)|
  acc << [project_id, k, v]
}.each {|l|
  p l.join(",")
}
```

executor
```bash
cat > Gemfile <<EOF
source "https://rubygems.org"

gem "google-cloud-monitoring"
EOF

bundle install

filter=xxx
log=result.csv

for proj in $(gcloud projects list | grep ${filter} | awk '{ print $1 }'); do
  bundle exec ruby check_cloudrun.rb ${proj} >> ${log}
done
```
