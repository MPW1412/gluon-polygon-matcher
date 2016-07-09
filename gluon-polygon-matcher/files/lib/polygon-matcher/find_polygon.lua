POLYGONS_BASE_URL = "http://firmware.freifunk-muensterland.de/md-fw-dl/shapes"
HTTP_TO_HTTPS_PROXY= 'http://firmware.freifunk-muensterland.de/approxy.php?aps='
WIFI_SCAN_COMMAND = 'iwinfo client0 scan'
-- WIFI_SCAN_COMMAND = 'iwlist wlan0 scan'
RUECKMELDUNGS_URL = 'http://firmware.freifunk-muensterland.de/knoten.php?dom='

domains = { count = 0 }
wifis = {}
JSON = (loadfile "JSON.lua")()

Url_encode_from = { '%{', '"', '%:', '%[', ',', '%]', '%}' }
Url_encode_to = { '%%7B', '%%22', '%%3A', '%%5B', '%%2C', '%%5D', '%%7D' }

function find_all_polygons()
	local file = assert(io.popen('wget -qO - ' .. POLYGONS_BASE_URL, 'r'))
	for line in file:lines() do
		if ( string.match(line, "geojson") and not string.match(line, "highres")) then
			line = string.gsub(line, "^.->", "", 1)
			line = string.gsub(line, "<.*", "", 1)
			domains["count"] = domains["count"] + 1
			domains[domains["count"]] = line
		end
	end
end
function report_polygon_match(count)
	domaene = domains[count]:gsub('^.-(%d+).-$', '%1')
	print("Dieser Knoten liegt im Polygon " .. domaene ..".")
	assert(io.popen('wget -qO - ' .. RUECKMELDUNGS_URL .. domaene, 'r'))
	print ('wget -qO - ' .. RUECKMELDUNGS_URL .. domaene)
end
function read_whole_file(file)
        local content = file:read("*all")
	file:close()
        return content
end
function test_polygon_contains_point(own_coordinates, polygon)
	c = false
	j = #polygon
	for i=1,#polygon,1 do
		if (not ( polygon[i][2] > own_coordinates[2] ) == ( polygon[j][2] > own_coordinates[2] )) and ( own_coordinates[1] < ( polygon[j][1] - polygon[i][1] ) * ( own_coordinates[2] - polygon[i][2] ) / ( polygon[j][2] - polygon[i][2] ) + polygon[i][1] ) then
			c = not c
		end
		j=i
	end
	return c
end
function test_all_polygons()
	for i = 1, domains["count"] do
		if i ~= 6 then
			local file = assert(io.popen('wget -qO - ' .. POLYGONS_BASE_URL .. '/' .. domains[i], 'r'))
			local polygon_json = read_whole_file(file)
			local polygon = JSON:decode(polygon_json)['features'][1]['geometry']['coordinates'][1]
			local contains = test_polygon_contains_point({ lng,lat}, polygon)
			if contains then
				report_polygon_match(i)
			end
		end
	end
end
function parse_wifis()
	local file = assert(io.popen(WIFI_SCAN_COMMAND))
	local counter = 0;
	for line in file:lines() do
		if line:find('Address') ~= nil then
			counter = counter + 1
			wifis[counter] = {}
			wifis[counter]["macAddress"] = line:gsub ('.*(%w%w:%w%w:%w%w:%w%w:%w%w:%w%w).*', '%1')
		elseif line:find('hannel') ~= nil then
			wifis[counter]["channel"] = line:match('%d+')
		elseif line:find('Signal') ~= nil then
			wifis[counter]["signalStrength"] = line:gsub( '.+Signal.+%-(%d%d).*', '%-%1')
		end
	end
end
function get_coordinates()
	post = {}
	post["wifiAccessPoints"] = wifis
	poststring = JSON:encode(post)
	for i=1,#Url_encode_from do
		poststring=poststring:gsub(Url_encode_from[i], Url_encode_to[i])
	end

	local file = assert(io.popen('wget -qO - ' .. HTTP_TO_HTTPS_PROXY .. poststring, 'r'))
	reply = ""
	for line in file:lines() do
		reply = reply .. line
	end
	json_reply = JSON:decode(reply)
	lat = json_reply["location"]["lat"]
	lng = json_reply["location"]["lng"]
	print(lat)
	print(lng)
end

parse_wifis()
get_coordinates()
find_all_polygons()
test_all_polygons()
