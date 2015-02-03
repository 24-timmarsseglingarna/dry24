json.array!(@sections) do |section|
  json.extract! section, :id, :point_id, :to_point_id, :distance
  json.url section_url(section, format: :json)
end
