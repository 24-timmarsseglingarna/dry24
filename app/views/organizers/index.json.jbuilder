json.array!(@organizers) do |organizer|
  json.extract! organizer, :id, :name, :fk_org_code
  json.url organizer_url(organizer, format: :json)
end
