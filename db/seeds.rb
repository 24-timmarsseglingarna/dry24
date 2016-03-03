# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Organizer.create(name: 'Svenska Kryssarklubbens Västkustkrets', fk_org_code: 'Vk')
Organizer.create(name: 'Svenska Kryssarklubbens Vänerkrets')
Organizer.create(name: 'Svenska Kryssarklubbens Blekingekrets', fk_org_code: 'Bl')
Organizer.create(name: 'Svenska Kryssarklubbens Dackekrets')
Organizer.create(name: 'Svenska Kryssarklubbens S:t Annakrets', fk_org_code: 'SA')
Organizer.create(name: 'Svenska Kryssarklubbens Västermälarkrets', fk_org_code: 'Vm')
Organizer.create(name: 'Svenska Kryssarklubbens Stockholmskrets', fk_org_code: 'St')
Organizer.create(name: 'Svenska Kryssarklubbens Eggesundskrets')
Organizer.create(name: 'Svenska Kryssarklubbens Bottenhavskrets')
Organizer.create(name: 'Svenska Kryssarklubbens Bottenvikskrets', fk_org_code: 'Sk')
Organizer.create(name: 'Svenska Kryssarklubbens Sörmlandskrets', fk_org_code: 'So')
