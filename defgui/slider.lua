local lua = require( "defgui.lualib" )
local Field = require( "defgui.field" )


-- Slider -----------------------------------------------
local Slider = {}

function Slider.new( form, id, x, y, handler, caption )
	local clickHandler = function( guiSelf, field, action_id, action )
		if action_id == hash( "touch" ) and action.pressed then 
			if gui.pick_node( field.rootNode, action.x, action.y ) then
				field:switch()

				-- call custom button handler, as well
				if handler then 
					handler( guiSelf, field, action_id, action )
				end
			end
		end
	end

	local field = Field.new( id, x, y, width, height, clickHandler )
	field.caption = caption or ""
	field.value = true


	local tmplNode = lua.guiGetNode( "slider/root" )
	assert( tmplNode, "You must have a node in your GUI which must be declared as a template for sliders in your form!" )

	local nodes = gui.clone_tree( tmplNode )

	field.rootNode = nodes[ hash( "slider/root" ) ]
	assert( field.rootNode, "Unable to access newly created slider/root node!" )

	gui.set_id( field.rootNode, id .. "/root" )
	gui.set_position( field.rootNode, vmath.vector3( x, y, 1 ) )
	gui.set_enabled( field.rootNode, true )

	field.captionNode = nodes[ hash( "slider/caption" ) ] 
	assert( field.captionNode, "Unable to access newly created slider/caption node!" )
	gui.set_id( field.captionNode, id .. "/caption" )
	gui.set_text( field.captionNode, caption )
	gui.set_enabled( field.captionNode, true )

	field.onNode = nodes[ hash( "slider/on" ) ] 
	assert( field.onNode, "Unable to access newly created slider/on node!" )
	gui.set_id( field.onNode, id .. "/on" )
	gui.set_enabled( field.onNode, true )
	
	field.offNode = nodes[ hash( "slider/off" ) ] 
	assert( field.offNode, "Unable to access newly created slider/off node!" )
	gui.set_id( field.offNode, id .. "/off" )
	gui.set_enabled( field.offNode, true )
	gui.set_color( field.offNode, vmath.vector4( 1, 1, 1, 0 ) )
	
	field.btnOnNode = nodes[ hash( "slider/btnOn" ) ] 
	assert( field.btnOnNode, "Unable to access newly created slider/on node!" )
	gui.set_id( field.btnOnNode, id .. "/bntOn" )
	gui.set_enabled( field.btnOnNode, true )
	
	field.btnOffNode = nodes[ hash( "slider/btnOff" ) ] 
	assert( field.btnOffNode, "Unable to access newly created slider/off node!" )
	gui.set_id( field.btnOffNode, id .. "/bntOff" )
	gui.set_enabled( field.btnOffNode, false )

	form:add( field )
	

	function field:isOn()
		return field.value
	end


	function field:switchOff()
		field.value = false
		
		gui.animate( field.onNode, "color.w", 0, gui.EASING_LINEAR, .3, 0, callback, gui.PLAYBACK_ONCE_FORWARD )
		gui.animate( field.offNode, "color.w", 1, gui.EASING_LINEAR, .3, 0, callback, gui.PLAYBACK_ONCE_FORWARD )
		
		gui.animate( field.btnOnNode, "position.x", 80, gui.EASING_LINEAR, .3, 0, function() 
			gui.set_enabled( field.btnOffNode, true )
			
			gui.set_enabled( field.btnOnNode, false )
			gui.set_position( field.btnOnNode, vmath.vector3( 0, 0, 0 ) )
		end )
	end


	function field:switchOn()
		field.value = true
		
		gui.animate( field.offNode, "color.w", 0, gui.EASING_LINEAR, .3, 0, callback, gui.PLAYBACK_ONCE_FORWARD )
		gui.animate( field.onNode, "color.w", 1, gui.EASING_LINEAR, .3, 0, callback, gui.PLAYBACK_ONCE_FORWARD )
		
		gui.animate( field.btnOffNode, "position.x", -80, gui.EASING_LINEAR, .3, 0, function() 
			gui.set_enabled( field.btnOnNode, true )

			gui.set_enabled( field.btnOffNode, false )
			gui.set_position( field.btnOffNode, vmath.vector3( 0, 0, 0 ) )
		end )
	end

	
	function field:switch( onOrOff )
		if field.value then 
			field:switchOff()
		else
			field:switchOn()
		end
	end


	function field:setColorCaption( color )
		field:setColor( "caption", color )
		gui.set_color( field.captionNode, field:getColor( "caption" ) )
	end

	
	function field:setFont( fontname )
		gui.set_font( field.captionNode, fontname )
	end

	
	return field
end


return Slider

