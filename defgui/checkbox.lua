require( "deflibs.defold" )

local lua = require( "deflibs.lualib" )
local Field = require( "defgui.field" )


-- Checkbox -----------------------------------------------
local Checkbox = {}

function Checkbox.new( form, id, x, y, handler, caption )
	local clickHandler = function( guiSelf, field, action_id, action )
		if guiIsClicked( field.rootNode, action_id, action ) then 
			field.value = not field.value
			if field.value then 
				gui.set_text( field.checkmarkNode, "X" )
			else
				gui.set_text( field.checkmarkNode, "" )
			end

			-- call custom button handler, as well
			if handler then 
				handler( guiSelf, field, action_id, action )
			end
		end
	end

	local field = Field.new( id, x, y, width, height, clickHandler )
	field.caption = caption or ""
	field.value = false


	local tmplNode = guiGetNode( "checkbox/root" )
	assert( tmplNode, "You must have a node in your GUI which must be declared as a template for checkboxes in your form!" )

	local nodes = gui.clone_tree( tmplNode )

	field.rootNode = nodes[ hash( "checkbox/root" ) ]
	assert( field.rootNode, "Unable to access newly created checkbox/root node!" )

	gui.set_id( field.rootNode, id .. "/root" )
	gui.set_position( field.rootNode, vmath.vector3( x, y, 1 ) )
	gui.set_enabled( field.rootNode, true )
	
	field.captionNode = nodes[ hash( "checkbox/caption" ) ] 
	assert( field.captionNode, "Unable to access newly created checkbox/caption node!" )

	gui.set_id( field.captionNode, id .. "/caption" )
	gui.set_text( field.captionNode, caption )
	
	field.checkmarkNode = nodes[ hash( "checkbox/checkmark" ) ] 
	assert( field.checkmarkNode, "Unable to access newly created checkbox/checkmark node!" )
	gui.set_id( field.checkmarkNode, id .. "/checkmark" )
	
	form:add( field )

	
	function field:isChecked()
		return field.value
	end


	function field:check( onOrOff )
		field.value = onOrOff
	end


	function field:setColorCaption( color )
		field:setColor( "caption", color )
		gui.set_color( field.captionNode, field:getColor( "caption" ) )
	end


	function field:setColorBox( color )
		field:setColor( "box", color )
		gui.set_color( field.rootNode, field:getColor( "box" ) )
	end

	function field:setColorX( color )
		field:setColor( "checkmark", color )
		gui.set_color( field.checkmarkNode, field:getColor( "checkmark" ) )
	end


	function field:setFont( fontname )
		gui.set_font( field.captionNode, fontname )
	end


	function field:setImage( atlasImgPath )
		local atlas, img = Texture( atlasImgPath )
		gui.set_texture( field.rootNode, atlas )
		gui.play_flipbook( field.rootNode, img )
	end


	return field
end


return Checkbox