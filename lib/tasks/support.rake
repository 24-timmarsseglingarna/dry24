#encoding: UTF-8

namespace :search do
  desc "Search for sections that interfere with each other."
  task :interference => :environment do
    puts 'P1-P2;distance12;P2-P3;distance23;P1-P3;distance13;how close'
    for point in Point.all do # loop all points
      for s1 in point.sections do
        for s2 in s1.to_point.sections do
          unless s2.to_point == point
            s3 = Section.find_by(point: point, to_point: s2.to_point)
            if s3.present?
              how_close = (s1.distance + s2.distance) / s3.distance
              if how_close < 1.00
                puts "#{s1.point.number_name} -- #{s1.to_point.number_name};#{s1.distance};#{s2.point.number} -- #{s2.to_point.number_name};#{s2.distance};#{s3.point.number} -- #{s3.to_point.number};#{s3.distance};#{((how_close * 100) - 100).round 1}%"
              end
            end
          end
        end
      end
    end
  end
end


