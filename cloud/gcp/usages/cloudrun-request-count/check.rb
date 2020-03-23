require "google/cloud/monitoring"

project_id = ARGV[0]

client       = Google::Cloud::Monitoring.metric_service
project_name = client.project_path(project: project_id)
filter       = 'metric.type="run.googleapis.com/request_count"'
view         = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL

now                 = Time.now
duration            = 60*60*24*7
interval            = Google::Cloud::Monitoring::V3::TimeInterval.new
interval.end_time   = Google::Protobuf::Timestamp.new(seconds: now.to_i, nanos: now.nsec)
interval.start_time = Google::Protobuf::Timestamp.new(seconds: now.to_i - duration, nanos: now.nsec)

aggregation = Google::Cloud::Monitoring::V3::Aggregation.new(
  alignment_period:   { seconds: 60*5 },
  group_by_fields:    ["resource.labels.service_name"],
  per_series_aligner: Google::Cloud::Monitoring::V3::Aggregation::Aligner::ALIGN_SUM,
)

result = {}
data = client.list_time_series(
  name:        project_name,
  filter:      filter,
  interval:    interval,
  view:        view,
  aggregation: aggregation,
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
