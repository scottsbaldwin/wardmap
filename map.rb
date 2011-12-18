require 'Date'

# Get the current date
today = Date.today
map_date = today.strftime "%B %e, %Y"
# Load up the configuration
config = eval(File.open('map.config').read)

# Load the directory of people in the ward
directorylines = File.open('directory.txt').readlines
# Load the grid of homes/positioning
gridlines = File.open('grid.txt').readlines

# Load the template files
template = File.open('template.html').read

# process the directory lines
directory = Hash[directorylines.map{|l| [l.chomp.split(",")[0], l.chomp.split(",")]}]
grid = Hash[gridlines.map{|l| [l.chomp.split(",")[0], l.chomp.split(",")]}]

# create the grid CSS, turn on the grid in the HTML, find
# <div id="gridpaper" style="display:none"></div>
# and change the style attribute to display:block
gridpaper_css = <<GRID

#gridpaper {
  opacity: 0.33;
  position: absolute;
  top: 0px;
  left: 0px;
  z-index:0;
  height: 1000px;
  width: 960px;
  margin: 0 0 20px 0;
  background-color: #eaeaea;
  background-image:
     -webkit-repeating-linear-gradient(0deg, rgba(0, 191, 255, .5), rgba(0, 191, 255, .5) 1px, transparent 1px, transparent 20px),
     -webkit-repeating-linear-gradient(90deg, rgba(255, 105, 180, .5), rgba(255, 105, 180, .5) 1px, transparent 1px, transparent 20px);
}
GRID

# Generate the CSS positioning for each house on the grid
house_css = ""
grid.each do |h|
	house_css += <<END
#house#{h[1][0]} {
        position: absolute;
        left: #{h[1][1]}px;
        top: #{h[1][2]}px;
        width: #{h[1][3]}px;
        height: #{h[1][4]}px;
        z-index: #{h[1][0]};
}
END
end

# Generate the CSS class for showing the categories on the map
categories_css_hide = <<END
.categories { display: none; }
END
categories_css_show = <<END
.categories { display: inline; }
END

# Generate the HTML/divs for each house on the grid
divs = ""
directory.each do |h|

divs += <<END
		<div id="house#{h[1][0]}" class="household" style="#{grid[h[0]][5] != nil ? 'text-align: ' + grid[h[0]][5] : ''}">
			<div class="name">#{h[1][2]}</div>
			<div class="street">#{h[1][1]}</div>
			<div class="number">##{h[1][0]} <span class="categories">
END

# Add the categories
if h[1][3] != nil
	h[1][3].chars.each do |c|
divs += <<END
				<span class="#{c}">#{c}</span>
END
	end
end

divs += <<END
			</span></div>
		</div>
END
end

# interpolate the variables
# WARD_NAME, STYLE_LABELS, HTML_LABELS, GENERATED_DATE
confidential = template

template = template.gsub(/WARD_NAME/, config[:ward_name])
confidential = confidential.gsub(/WARD_NAME/, config[:ward_name])

template = template.gsub(/STYLE_LABELS/, "#{gridpaper_css}\n#{house_css}\n#{categories_css_hide}")
confidential = confidential.gsub(/STYLE_LABELS/, "#{gridpaper_css}\n#{house_css}\n#{categories_css_show}")

template = template.gsub(/HTML_LABELS/, divs)
confidential = confidential.gsub(/HTML_LABELS/, divs)

template = template.gsub(/GENERATED_DATE/, map_date)
confidential = confidential.gsub(/GENERATED_DATE/, map_date)

# save the template based on the :output_file_normal
# configuration, e.g. WardMap.html
File.open(config[:output_file_normal], 'w') { |f| f.write(template) }
puts "Map saved to #{config[:output_file_normal]}"

# save the confidential template based on the :output_file_confidential
# configuration, e.g. WardMap-confidential.html
File.open(config[:output_file_confidential], 'w') { |f| f.write(confidential) }
puts "Confidential map saved to #{config[:output_file_confidential]}"
