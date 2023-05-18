
-- Utility functions --------------------------------------
function nodeTextSize( node, txt )
	assert( node, "Text node must not be nil!" )
	if txt == nil then txt = "" end

	local font = gui.get_font( node )
	local endCharWidth = gui.get_text_metrics( font, "." ).width
	local metrics = gui.get_text_metrics( font, txt .. "." )
	local width = metrics.width - endCharWidth
	local height = metrics.height

	return { width = width, height = height }
end


function Color( hex, alpha )
	if hex == nil then return nil end

	if hex:startsWith( "#" ) then 
		hex = string.sub( hex, 2, string.len( hex ) ) 
	end

	local r, g, b = hex:match( "(%w%w)(%w%w)(%w%w)" )
	r = ( tonumber( r, 16 ) or 0 ) / 255
	g = ( tonumber( g, 16 ) or 0 ) / 255
	b = ( tonumber( b, 16 ) or 0 ) / 255

	return vmath.vector4( r, g, b, alpha or 1 )
end


function Texture( url, default ) 
	local atlas = ""
	local img = ""

	if default ~= nil then 
		local parts = default:split( "/" )
		atlas = parts[ 1 ]
		img = parts[ 2 ]
	end

	if url ~= nil then 
		local parts = url:split( "/" )
		atlas = parts[ 1 ]
		img = parts[ 2 ]
	end

	return atlas, img
end


function guiGetNode( id )
	local ok, result = pcall( gui.get_node, id )
	if ok then 
		return result
	else
		pprint( "Error: " .. result ) 
	end
end


function contains( tab, value )
	for key, item in pairs( tab ) do
		if item == value then
			return true
		end
	end

	return false
end


function string.split( self, delim )
	local t = {} 
	local wordStart = 1
	local delimStart, delimEnd 
	while true  do
		delimStart, delimEnd = self:find( delim, wordStart, true )
		if delimStart == nil then 
			if wordStart <= #self then 
				table.insert( t, self:sub( wordStart ))
			end 
			break
		end
		table.insert( t, self:sub( wordStart, delimStart - 1 ) )
		wordStart = delimEnd + 1
	end 
	return t
end
 

string.startsWith = function( s, start )
	return s:sub( 1, #start ) == start
end
