require "google/cloud/monitoring"

project_id = ARGV[0]

client       = Google::Cloud::Monitoring.metric_service
project_name = client.project_path(project: project_id)
filter       = 'metric.type="logging.googleapis.com/billing/bytes_ingested"'
view         = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL

now                 = Time.now
today               = Time.new(now.year, now.month, now.day-1, 0, 0, 0, 0)
duration            = 60*60*24*7
interval            = Google::Cloud::Monitoring::V3::TimeInterval.new
interval.end_time   = Google::Protobuf::Timestamp.new(seconds: today.to_i, nanos: today.nsec)
interval.start_time = Google::Protobuf::Timestamp.new(seconds: today.to_i - duration, nanos: today.nsec)

aggregation = Google::Cloud::Monitoring::V3::Aggregation.new(
  alignment_period:   { seconds: 60*5 },
  group_by_fields: [],
  per_series_aligner: Google::Cloud::Monitoring::V3::Aggregation::Aligner::ALIGN_SUM,
)

result = {}
data = client.list_time_series(
  name:     project_name,
  filter:   filter,
  interval: interval,
  view:     view
)
data.each do |ts|
  label = ts.metric.labels["resource_type"]
  val = ts.points.map(&:value).map(&:int64_value).sum

  if result[label].nil?
    result[label] = val
  else
    result[label] += val
  end
end

result.reduce([]) {|acc, (k, v)|
  acc << [project_id, k, v.to_f/1000/1000/1000]
}.each {|l|
  p l.join(",")
}
