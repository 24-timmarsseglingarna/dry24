#encoding: UTF-8
require 'nokogiri'
require 'open-uri' 
require 'erb'
include ERB::Util


namespace :import do
  desc "Initial import of points from P&D database."
  task :points => :environment do 
    doc = Nokogiri::XML(open("http://dev.24-timmars.nu/PoD/api/xmlapi2.php?points"), nil, 'ISO-8859-1'  )
    # TODO set character encoding
    doc.xpath("//punkter//punkt//nummer").each do |number|
      p = Point.find_or_create_by(number: number.content.to_s.strip)
      p.save!
    end
  end
end

namespace :populate do
  task :points => :environment do
    Point.all.each do |point|
      doc = Nokogiri.XML(open("http://dev.24-timmars.nu/PoD/xmlapi.php?point=#{url_encode(point.number)}"), nil, 'ISO-8859-1')
      name = doc.xpath("//PoD//punkt//namn").first.content
      point.name = doc.xpath("//PoD//punkt//namn").first.content.strip
      point.definition = doc.xpath("//PoD//punkt//definition").first.content.strip  
      point.lat = doc.xpath("//PoD//punkt//lat").first.content.strip    
      point.long = doc.xpath("//PoD//punkt//long").first.content.strip
      point.save!
    end
  end
  
  task :start_points => :environment do
    Organizer.all.each do |organizer|
      unless organizer.fk_org_code.blank?
        doc = Nokogiri.XML(open("http://dev.24-timmars.nu/PoD/xmlapi.php?krets=#{url_encode(organizer.fk_org_code.strip)}"), nil, 'ISO-8859-1')
        doc.xpath("//startpunkter//startpunkt//nummer").each do |number|
          point = Point.find_by_number number.content.strip
          unless organizer.points.include? point
            organizer.points << point
          end
        end
      end
    end
  end  
  
end


namespace :destroy do
  task :points => :environment do
    Point.destroy_all
  end
end