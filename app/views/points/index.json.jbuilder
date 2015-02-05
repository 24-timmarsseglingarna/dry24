json.array!(@points) do |point|
  json.extract! point, :id, :number, :name, :latitude, :longitude, :definition
  json.url point_url(point, format: :json)
end
