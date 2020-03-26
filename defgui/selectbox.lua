require( "defgui.utils" )

local lua = require( "defgui.lualib" )
local Field = require( "defgui.field" )


-- Selectbox --------------------------------------------------
local Item = {}
function Item.new( caption, name )
	local i = {}
	i.caption = caption 
	i.name = name

	return i
end

local Selectbox = {}
function Selectbox.new( form, id, x, y, width, height, selecthandler )
	local openhandler = function( guiSelf, field, action_id, action )
		if action_id == hash( "touch" ) and action.pressed then 
			if gui.pick_node( field.rootNode, action.x, action.y ) then
				print( "Open..." )
			end
		end
	end
	
	local field = Field.new( id, x, y, width, height, openhandler )
	field.items = {}
	field.yOffset = 0
	field.selectedIndex = 0

	local tmplNode = lua.guiGetNode( "selectbox/root" )
	assert( tmplNode, "You must have a node in your GUI which must be declared as a template for selectboxes in your form!" )

	local nodes = gui.clone_tree( tmplNode )

	field.rootNode = nodes[ hash( "selectbox/root" ) ]
	assert( field.rootNode, "Unable to access newly created selectbox/root node!" )
	
	field.opener = nodes[ hash( "selectbox/opener" ) ]
	assert( field.opener, "Unable to access newly created selectbox/opener node!" )
	
	field.openerTxt = nodes[ hash( "selectbox/txt" ) ]
	assert( field.openerTxt, "Unable to access newly created selectbox/opener/txt node!" )
	
	field.list = nodes[ hash( "selectbox/list" ) ]
	assert( field.items, "Unable to access newly created selectbox/list node!" )
	
	field.selected = nodes[ hash( "selectbox/selected" ) ]
	assert( field.selected, "Unable to access newly created selectbox/selected node!" )
	
	field.clip = nodes[ hash( "selectbox/clip" ) ]
	assert( field.clip, "Unable to access newly created selectbox/clip node!" )
	
	gui.set_id( field.opener, id .. "/opener" )
	local openerSize = gui.get_size( field.opener )
	gui.set_position( field.opener, vmath.vector3( width - openerSize.x, 0, 0 ) )
	gui.set_enabled( field.opener, true )

	gui.set_id( field.openerTxt, id .. "/openerTxt" )
	gui.set_position( field.openerTxt, vmath.vector3( 6, 4, 0 ) )
	gui.set_enabled( field.openerTxt, true )
	
	gui.set_id( field.rootNode, id .. "/root" )
	gui.set_position( field.rootNode, vmath.vector3( x, y, 0 ) )
	gui.set_size( field.rootNode, vmath.vector3( width, openerSize.y, 1 ) )
	gui.set_enabled( field.rootNode, true )

	gui.set_id( field.selected, id .. "/selected" )
	gui.set_position( field.selected, vmath.vector3( 4, -4, 0 ) )
	gui.set_size( field.selected, vmath.vector3( width - 8, openerSize.y - 4, 1 ) )
	gui.set_enabled( field.selected, true )
	
	gui.set_id( field.list, id .. "/list" )
	gui.set_position( field.list, vmath.vector3( 0, -1 * openerSize.y - 1, 0 ) )
	gui.set_size( field.list, vmath.vector3( width, height - openerSize.y, 1 ) )
	gui.set_enabled( field.list, true )
	
	gui.set_id( field.clip, id .. "/clip" )
	gui.set_position( field.clip, vmath.vector3( 0, -1 * openerSize.y - 1, 0 ) )
	gui.set_size( field.clip, vmath.vector3( width, height - openerSize.y, 1 ) )
	gui.set_enabled( field.clip, true )

	form:add( field )
	
	
	function field:textSize( txt )
		if txt == nil then txt = field.value end
		return nodeTextSize( field.rootNode, txt )
	end
	

	function field:select( itemIndex )
		if itemIndex < 1 or itemIndex > #field.items then return end
			
		field.selectedIndex = itemIndex
		gui.set_text( field.selected, field.items[ field.selectedIndex ].caption )
	end

	
	function field:addItem( caption, value )
		local item = Item.new( caption, value )
		table.insert( field.items, item )

		-- first and only item so far: select it
		if field.selectedIndex == 0 then 
			field:select( 1 ) 
		end
	end

	
	return field
end




return Selectbox