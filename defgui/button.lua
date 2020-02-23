local lua = require( "defgui.lualib" )
local Field = require( "defgui.field" )


-- Button -----------------------------------------------
local Button = {}

function Button.new( form, id, x, y, width, height, handler, caption )
	local clickHandler = function( guiSelf, field, action_id, action )
		if action_id == hash( "touch" ) and action.pressed then 
			if gui.pick_node( field.rootNode, action.x, action.y ) then
				field:blink()
				-- call custom button handler, as well
				if handler then 
					handler( guiSelf, field, action_id, action )
				end
			end
		end
	end

	local field = Field.new( id, x, y, width, height, clickHandler )
	field.caption = caption or ""

	local tmplNode = lua.guiGetNode( "button/root" )
	assert( tmplNode, "You must have a node in your GUI which must be declared as a template for buttons in your form!" )
	
	local nodes = gui.clone_tree( tmplNode )
	
	field.rootNode = nodes[ hash( "button/root" ) ]
	assert( field.rootNode, "Unable to access newly created button/root node!" )

	gui.set_id( field.rootNode, id .. "/root" )
	gui.set_position( field.rootNode, vmath.vector3( x, y, 1 ) )
	gui.set_size( field.rootNode, vmath.vector3( width, height, 1 ) )
	gui.set_enabled( field.rootNode, true )
	
	field.captionNode = nodes[ hash( "button/caption" ) ] 
	assert( field.captionNode, "Unable to access newly created button/caption node!" )

	gui.set_id( field.captionNode, id .. "/caption" )
	gui.set_text( field.captionNode, caption )
	gui.set_size( field.captionNode, vmath.vector3( width, height, 1 ) )

	form:add( field )
	

	function field:blink() 
		local col = gui.get_color( field.rootNode )
		gui.animate( field.rootNode, gui.PROP_COLOR, vmath.vector4( col.x, col.y, col.z, col.w * 0.3 ), gui.EASING_LINEAR, 0.1, 0, 
			function( self, node ) 
				gui.animate( field.rootNode, gui.PROP_COLOR, vmath.vector4( col.x, col.y, col.z, col.w ), gui.EASING_LINEAR, 0.1 )
			end 
		)
	end


	function field:textSize( txt )
		if txt == nil then txt = field.value end
		return nodeTextSize( field.captionNode, txt )
	end


	function field:setColorCaption( color )
		field:setColor( "caption", color )
		gui.set_color( field.captionNode, field:getColor( "caption" ) )
	end


	function field:setColorBG( color )
		field:setColor( "background", color )
		gui.set_color( field.rootNode, field:getColor( "background" ) )
	end


	-- center caption (without having to rely on gui alignment)
	local rootSize = gui.get_size( field.rootNode )
	local captionPos = gui.get_position( field.captionNode )
	local txtSize = field:textSize( field.caption )
	captionPos.x = ( rootSize.x - txtSize.width ) / 2
	captionPos.y = -1 * ( rootSize.y - txtSize.height ) / 2 
	gui.set_position( field.captionNode, captionPos )

	return field
end



return Button