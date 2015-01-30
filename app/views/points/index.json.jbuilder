json.array!(@points) do |point|
  json.extract! point, :id, :number, :name, :lat, :long, :definition
  json.url point_url(point, format: :json)
end
