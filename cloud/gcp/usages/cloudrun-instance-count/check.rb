require "google/cloud/monitoring"

project_id = ARGV[0]

client       = Google::Cloud::Monitoring.metric_service
project_name = client.project_path project: project_id
filter       = 'metric.type="run.googleapis.com/container/instance_count"'
view         = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL

now                 = Time.now
duration            = 60*60*24*7
interval            = Google::Cloud::Monitoring::V3::TimeInterval.new
interval.end_time   = Google::Protobuf::Timestamp.new(seconds: now.to_i, nanos: now.nsec)
interval.start_time = Google::Protobuf::Timestamp.new(seconds: now.to_i - duration, nanos: now.nsec)

result = {}
data = client.list_time_series(
  name:     project_name,
  filter:   filter,
  interval: interval,
  view:     view,
)
data.each do |ts|
  if ts.metric.labels["state"] == "active"
    label = ts.resource.labels["service_name"]
    val = ts.points.map(&:value).map(&:int64_value).max

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
