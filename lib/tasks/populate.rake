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
      #name = doc.xpath("//PoD//punkt//namn").first.content
      point.name = doc.xpath("//PoD//punkt//namn").first.content.strip.encode("iso-8859-1").force_encoding("utf-8")
      point.definition = doc.xpath("//PoD//punkt//definition").first.content.strip.encode("iso-8859-1").force_encoding("utf-8")
      point.lat = doc.xpath("//PoD//punkt//lat").first.content.strip.encode("iso-8859-1").force_encoding("utf-8")
      point.long = doc.xpath("//PoD//punkt//long").first.content.strip.encode("iso-8859-1").force_encoding("utf-8")
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







end


namespace :destroy do
  task :points => :environment do
    Point.destroy_all
  end
end