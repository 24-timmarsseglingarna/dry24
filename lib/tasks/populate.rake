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
      p = Point.find_or_create_by(number: number.content.to_s.strip.to_i)
      p.save!
    end
  end
end

namespace :populate do
  task :points => :environment do
    Point.all.each do |point|
      doc = Nokogiri.XML(open("http://dev.24-timmars.nu/PoD/xmlapi.php?point=#{url_encode(point.number)}"), nil, 'ISO-8859-1')
      #name = doc.xpath("//PoD//punkt//namn").first.content
      point.name = doc.xpath("//PoD//punkt//namn").first.content.strip.encode("iso-8859-1").force_encoding("utf-8")
      point.definition = doc.xpath("//PoD//punkt//definition").first.content.strip.encode("iso-8859-1").force_encoding("utf-8")
      lat = doc.xpath("//PoD//punkt//lat").first.content.strip.encode("iso-8859-1").force_encoding("utf-8")
      long = doc.xpath("//PoD//punkt//long").first.content.strip.encode("iso-8859-1").force_encoding("utf-8")
      point.longitude = (long.split[0].to_d + long.split[1].gsub(/,/, ".").to_d/60).to_f
      point.latitude = (lat.split[0].to_d + lat.split[1].gsub(/,/, ".").to_d/60).to_f
      point.save!
      puts "---#{point.number_name}  ---"
      doc.search("tillpunkter").search("punkt").each do |other_end|
        o = Point.find_by_number other_end.search("nummer").first.content.strip.to_i
        s = Section.find_or_create_by(point: point, to_point: o)
        s.distance = other_end.search("distans").first.content.strip.to_f
        s.save!
      end


    end
  end

  task :start_points => :environment do
    Organizer.all.each do |organizer|
      unless organizer.fk_org_code.blank?
        doc = Nokogiri.XML(open("http://dev.24-timmars.nu/PoD/xmlapi.php?krets=#{url_encode(organizer.fk_org_code.strip)}"), nil, 'ISO-8859-1')
        doc.xpath("//startpunkter//startpunkt//nummer").each do |number|
          point = Point.find_by_number number.content.strip.to_i
          unless organizer.start_points.include? point
            organizer.start_points << point
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

  task :sections => :environment do
    Section.destroy_all
  end

  task :crews => :environment do
    Crew.destroy_all
  end

  task :log_entries => :environment do
    LogEntry.destroy_all
  end

end