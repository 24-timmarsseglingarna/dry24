module CrewsHelper

  def go_section(section)

    raw "⇒ #{section.to_point.number_name}
          (#{Geocoder::Calculations.compass_point(section.point.bearing_to(section.to_point)).to_s}
          #{section.distance.to_s} M). <br><span class='defi'>#{section.to_point.definition}</span>"
  end

  def display_my(points)
    str = ''
    for point in points
      str += '.formtastic li#crew_start_point_input li label[for="crew_start_point_id_' + point.id.to_s + '"] {display: initial;}'
    end
    str
  end

end


#link_to(go_section(section), create_log_entry_crew_url(:to_point_id => section.to_point.id), :method => :post)