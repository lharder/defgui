require( "defgui.stringutils" )
local lua = require( "defgui.lualib" )


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


function raycast( from, to, group, color )
	if color ~= nil then 
		msg.post( "@render:", "draw_line", { start_point = from, end_point = to, color = color } )
	end
	return physics.raycast( from, to, group )
end



function formatNameValue( strLft, delim, strRgt, width, font )
	local wFill = width - gui.get_text_metrics( font, strLft .. strRgt ).width 
	local wChr = gui.get_text_metrics( font, delim ).width 
	local cnt = lua.round( wFill / wChr )
	local s = strLft .. string.rep( delim, cnt ) .. strRgt

	-- correction atempt: can only approximate, a space is thin
	if gui.get_text_metrics( font, s ).width < width then
		s = strLft .. " " .. string.rep( delim, cnt ) .. strRgt
	end
	
	return s
end


-- turn towards another go
function goRotateTo( other, me )
	if me == nil then me = "." end

	local direction = go.get_world_position( other ) - go.get_world_position( me )
	local angle = math.atan2( direction.y, direction.x )
	local rotation = vmath.quat_rotation_z( angle )	

	go.set_rotation( rotation, me )
end


-- turn towards a given position at speed dt
function goRotateToPos( me, otherPos, dt )
	if dt == nil then dt = 1 end

	local mePos = go.get_world_position( me )

	local dx = mePos.x - otherPos.x
	local dy = mePos.y - otherPos.y   
	local radians = math.atan2( dy, dx ) + math.rad( 90 )

	go.set_rotation( vmath.slerp( dt, 
		go.get_world_rotation( me ), 
		vmath.quat_rotation_z( radians ) ) 
	)
end 


-- relative by xx degrees
function goRotateBy( degrees, id, dt )
	if dt == nil then dt = 0.05 end
	
	local rot = go.get_rotation( id )
	go.set_rotation( rot * vmath.quat_rotation_z( dt ), id )
end


-- absolute angle
function goRotate( degrees, id )
	go.set_rotation( vmath.quat_rotation_z( math.rad( degrees ) ), id )
end



function goExists( id )
	local ok, result = pcall( go.get_position, id )
	return ok
end


function goSpriteExists( url )
	local ok, result = pcall( go.cancel_animations, url, "" )
	-- local ok, result = pcall( msg.post, url, "" )
	-- local ok, result = pcall( go.get, url, "" )
	return ok
end


function goGetProperty( id, name )
	local ok, result = pcall( go.get, id, name )
	if ok then return result else return nil end
end


-- Beware: disabled nodes DO receive clicks! 
-- Totally unexpected behavior, correct!
function guiIsClicked( node, action_id, action )
	if node == nil then return false end
	if action_id == hash( "touch" ) and action.pressed then 
		return gui.is_enabled( node ) and gui.pick_node( node, action.x, action.y ) 
	end
	return false
end



function guiGetNode( id )
	local ok, result = pcall( gui.get_node, id )
	if ok then 
		return result
	else
		pprint( "Error: " .. result ) 
	end
end



-- allow for either separated parameters for atlas, image
-- or alternatively an image path with a divider "atlas/image"
function guiSetImage( node, image, atlas )
	if image == nil then return end 

	if atlas == nil then 
		if image:indexOf( "/" ) > -1 then
			local parts = image:split( "/" )
			atlas = parts[ 1 ]
			image = parts[ 2 ]
		end  
	end

	if atlas ~= nil then
		gui.set_texture( node, atlas )
	end

	gui.play_flipbook( node, image )
end


function guiBlink( node, interval, opacity, stopAfterSecs, callback )
	if opacity == nil then opacity = 0 end
	if interval == nil then interval = 1 end

	local colOn = gui.get_color( node )
	gui.animate( node, "color.w", opacity, gui.EASING_LINEAR, interval, 0, nil, gui.PLAYBACK_LOOP_PINGPONG )

	if stopAfterSecs ~= nil then 
		timer.delay( stopAfterSecs, false, function() 
			gui.cancel_animation( node, "color.w" )
			gui.set_color( node, colOn )
			if callback then callback() end
		end )
	end
end


function guiScaleIn( node, secs, size, callback )
	if size == nil then size = 1 end
	
	gui.set_scale( node, vmath.vector4() )
	gui.animate( node, gui.PROP_SCALE, size, gui.EASING_LINEAR, secs, 0, callback )
end 


function guiMoveIn( node, pos, secs, callback )
	gui.animate( node, gui.PROP_POSITION, pos, gui.EASING_LINEAR, secs, 0, function() 
		if callback ~= nil then callback() end
	end )
end




		