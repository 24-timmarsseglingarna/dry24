json.array!(@crews) do |crew|
  json.extract! crew, :id, :boat_name, :captain_name, :captain_email
  json.url crew_url(crew, format: :json)
end
