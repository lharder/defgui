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
function Selectbox.new( form, id, x, y, width, height, myselecthandler )
	
	local openhandler = function( guiSelf, field, action_id, action )
		if action_id == hash( "touch" ) and action.pressed then 
			if gui.pick_node( field.rootNode, action.x, action.y ) then
				pprint( "open: " .. tostring( field.isOpen ) )

				field:blink()
				field:showList( not field.isOpen )
			end
		end
	end
	
	local field = Field.new( id, x, y, width, height, openhandler )
	field.items = {}
	field.selectedIndex = 0
	field.isOpen = false
	field.animDone = true

	local tmplNode = lua.guiGetNode( "selectbox/root" )
	assert( tmplNode, "You must have a node in your GUI which must be declared as a template for selectboxes in your form!" )

	local nodes = gui.clone_tree( tmplNode )

	field.rootNode = nodes[ hash( "selectbox/root" ) ]
	assert( field.rootNode, "Unable to access newly created selectbox/root node!" )
	
	field.opener = nodes[ hash( "selectbox/opener" ) ]
	assert( field.opener, "Unable to access newly created selectbox/opener node!" )
	
	field.openerTxt = nodes[ hash( "selectbox/txt" ) ]
	assert( field.openerTxt, "Unable to access newly created selectbox/opener/txt node!" )
	
	field.selected = nodes[ hash( "selectbox/selected" ) ]
	assert( field.selected, "Unable to access newly created selectbox/selected node!" )
	
	field.clip = nodes[ hash( "selectbox/clip" ) ]
	assert( field.clip, "Unable to access newly created selectbox/clip node!" )

	field.entryTmpl = nodes[ hash( "selectbox/entry" ) ]
	assert( field.entryTmpl, "Unable to access newly created selectbox/entry node!" )
	
	gui.set_id( field.opener, id .. "/opener" )
	local openerSize = gui.get_size( field.opener )
	gui.set_position( field.opener, vmath.vector3( width - openerSize.x, 0, 0 ) )
	gui.set_enabled( field.opener, true )

	gui.set_id( field.openerTxt, id .. "/openerTxt" )
	-- gui.set_position( field.openerTxt, vmath.vector3( 14, -12, 0 ) )
	gui.set_enabled( field.openerTxt, true )
	
	gui.set_id( field.rootNode, id .. "/root" )
	gui.set_position( field.rootNode, vmath.vector3( x, y, 0 ) )
	gui.set_size( field.rootNode, vmath.vector3( width, openerSize.y, 1 ) )
	gui.set_enabled( field.rootNode, true )

	gui.set_id( field.selected, id .. "/selected" )
	gui.set_position( field.selected, vmath.vector3( 4, -4, 0 ) )
	gui.set_size( field.selected, vmath.vector3( width - 8, openerSize.y - 4, 1 ) )
	gui.set_enabled( field.selected, true )
	
	gui.set_id( field.clip, id .. "/clip" )
	gui.set_position( field.clip, vmath.vector3( 0, -1 * openerSize.y - 1, 0 ) )
	gui.set_size( field.clip, vmath.vector3( width, height - openerSize.y, 1 ) )
	gui.set_enabled( field.clip, false )

	gui.set_id( field.entryTmpl, id .. "/entry" )
	gui.set_position( field.entryTmpl, vmath.vector3( 4, 0, 0 ) )
	gui.set_enabled( field.entryTmpl, false )

	form:add( field )
	

	function field:createItemList()
		pprint( "createList" )
		
		local txtHeight = nodeTextSize( field.entryTmpl, "o" ).height
		local yDelta = txtHeight + 4 
		local yDirection = -1
		local openerSize = gui.get_size( field.opener )
		local yOffset = -yDelta + 1
		
		gui.set_size( field.entryTmpl, vmath.vector3( field.width - 8, yDelta, 1 ) )

		field.itemNodes = {}
		local pos = nil
		for i, item in ipairs( field.items ) do
			pos = vmath.vector3( 4, -1 * yOffset + ( yDirection * yDelta * i ), 0 )
			
			field.itemNodes[ i ] = gui.clone( field.entryTmpl )
			gui.set_position( field.itemNodes[ i ], pos )
			gui.set_text( field.itemNodes[ i ], item.caption )
			gui.set_enabled( field.itemNodes[ i ], false )
		end
	end


	function field:showList( state )
		pprint( "showList" )
		
		if state == nil then state = true end

		for i, node in ipairs( field.itemNodes ) do
			gui.set_enabled( field.itemNodes[ i ], state )
		end
		gui.set_enabled( field.clip, state )

		field.isOpen = state
	end
	

	function field:blink() 
		if field.animDone then
			field.animDone = false
			local col = gui.get_color( field.opener )
			gui.animate( field.opener, gui.PROP_COLOR, vmath.vector4( col.x, col.y, col.z, col.w * 0.3 ), gui.EASING_LINEAR, 0.1, 0, 
					function( self, node ) 
						gui.animate( field.opener, gui.PROP_COLOR, vmath.vector4( col.x, col.y, col.z, col.w ), gui.EASING_LINEAR, 0.1, 0, 
						function() field.animDone = true end
					)
				end 
			)
		end
	end

	
	function field:textSize( txt )
		if txt == nil then txt = field.value end
		return nodeTextSize( field.rootNode, txt )
	end


	function field:setFont( fontname )
		gui.set_font( field.txtNode, fontname )
		gui.set_font( field.cursorNode, fontname )

		-- need to adjust reference width of chars
		field.charWidth = field:textSize( "o" ).width
	end
	

	function field:select( itemIndex )
		if itemIndex < 1 or itemIndex > #field.items then return end
			
		field.selectedIndex = itemIndex
		gui.set_text( field.selected, field.items[ field.selectedIndex ].caption )
	end

	
	function field:addItem( caption, value, doNotCreateNewList )
		local item = Item.new( caption, value )
		table.insert( field.items, item )

		-- first and only item so far: select it
		if field.selectedIndex == 0 then 
			field:select( 1 ) 
		end

		if not doNotCreateNewList then 
			field:createItemList()
		end
	end


	function field:setItems( items )
		assert( items, "Items muzst not be nil!" )

		local item = nil
		for i, v in ipairs( items ) do
			if type( v ) == "string" then 
				item = Item.new( v )
			else 
				item = v
			end
			field:addItem( item.caption, item.value, true )
		end

		-- create list only once, more efficient
		field:createItemList()
	end

	
	return field
end


return Selectbox
