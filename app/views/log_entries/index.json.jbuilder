json.array!(@log_entries) do |log_entry|
  json.extract! log_entry, :id, :point_id, :to_point_id, :from_time, :to_time, :description, :poition
  json.url log_entry_url(log_entry, format: :json)
end
