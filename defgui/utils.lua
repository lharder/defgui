
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


