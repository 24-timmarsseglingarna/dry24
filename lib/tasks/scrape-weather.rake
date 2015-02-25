namespace :scrape do
  require 'nokogiri'
  require 'open-uri'
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper



  desc "Scrape weather"
  task :weather => :environment do
    Dir.foreach("/home/stefan/tmp/kustobs") do |fname|
      doc = Nokogiri::HTML(File.open("/home/stefan/tmp/kustobs/#{fname}"))
      doc.xpath('//blockquote[(((count(preceding-sibling::*) + 1) = 6) and parent::*)]').each do |row|
        puts "*****row:  #{row}"
      end
    end
  end

end
