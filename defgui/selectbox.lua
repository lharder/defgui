require( "defgui.utils" )

local gesture = require( "in.gesture" )
local lua = require( "defgui.lualib" )
local Field = require( "defgui.field" )


-- Selectbox --------------------------------------------------
local Item = {}
function Item.new( caption, name )
	local item = {}
	item.caption = caption 
	item.name = name

	return item
end


local function getSweepSpeed( swipe )
	if swipe == nil then return 0 end
	
	local dist = vmath.length( swipe.to - swipe.from )
	return dist / swipe.time
end

local function isBigSwipe( swipe )
	return getSweepSpeed( swipe ) >= 500
end



local Selectbox = {}
function Selectbox.new( form, id, x, y, width, height, cntOpenItems, selecthandler )
	
	local clickhandler = function( guiSelf, field, action_id, action )

		-- check for swips up / down (anywhere on screen!) to scroll item list
		if field:isOpen() then
			local g = gesture.on_input( guiSelf, action_id, action )
			if g then
				if g.swipe_up then 
					local index
					if isBigSwipe( g.swipe ) then 
						index = field.offsetList + 3 * field.cntOpenItems 
					else 
						index = field.offsetList + field.cntOpenItems - 1
					end 
					if index > #field.items - field.cntOpenItems then 
						index = #field.items - field.cntOpenItems 
					end
					field:scrollTo( index )

				elseif g.swipe_down then 
					local index
					if isBigSwipe( g.swipe ) then 
						index = field.offsetList - 3 * field.cntOpenItems 
					else 
						index = field.offsetList - field.cntOpenItems
					end
					if index < 0 then index = 0 end
					field:scrollTo( index )

				end
			end
		end
		
		if action_id == hash( "touch" ) and action.pressed then 
			-- toggle open/close button to show/hide list of items
			if gui.pick_node( field.rootNode, action.x, action.y ) then
				field:blink()
				field:showList( not field:isOpen() )

			else
				-- check items for click
				for i, node in ipairs( field.itemNodes ) do
					if gui.pick_node( node, action.x, action.y ) then
					field.selectedIndex = i
						if field.customSelecthandler ~= nil then 
							-- call user's custom handler if provided
							field.customSelecthandler( field.items[ i ] )
						end
						break
					end
				end
			end
		end
	end
	
	local field = Field.new( id, x, y, width, height, clickhandler )
	field.items = {}
	field.selectedIndex = 0
	field.customSelecthandler = selecthandler
	field.animDone = true
	field.cntOpenItems = cntOpenItems
	field.offsetList = 0

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

	field.list = nodes[ hash( "selectbox/list" ) ]
	assert( field.list, "Unable to access newly created selectbox/list node!" )
	
	field.entryTmpl = nodes[ hash( "selectbox/entry" ) ]
	assert( field.entryTmpl, "Unable to access newly created selectbox/entry node!" )

	form:add( field )


	function field:getItemHeight()
		return nodeTextSize( field.entryTmpl, "o" ).height + 4
	end


	function field:isOpen()
		if field.list ~= nil then 
			return gui.is_enabled( field.list )
		end
	end


	function field:scrollTo( index )
		local del = index - field.offsetList 
		local yDel = del * field:getItemHeight() 
		local pos = gui.get_position( field.list )
		pos.y = pos.y + yDel
		
		gui.animate( field.list, hash( "position.y" ), pos.y, gui.EASING_OUTELASTIC, 2, 0, 
			function() 
				field.offsetList = index
			end
		)
	end

	
	function field:createItemList()
		-- simple: delete all previous nodes
		if field.itemNodes ~= nil then
			for i, item in ipairs( field.itemNodes ) do
				gui.delete_node( field.itemNodes[ i ] )
			end
		end

		-- create new list
		local yDelta = field:getItemHeight()
		local yDirection = -1
		local openerSize = gui.get_size( field.opener )
		local yOffset = -yDelta + 1
		
		gui.set_size( field.entryTmpl, vmath.vector3( field.width - 8, yDelta, 1 ) )

		field.itemNodes = {}
		local pos = nil
		for i, item in ipairs( field.items ) do
			pos = vmath.vector3( 4, -1 * yOffset + ( yDirection * yDelta * i ), 0 )
			
			field.itemNodes[ i ] = gui.clone( field.entryTmpl )
			gui.set_parent( field.itemNodes[ i ], field.list )
			gui.set_position( field.itemNodes[ i ], pos )
			gui.set_text( field.itemNodes[ i ], item.caption )
			gui.set_enabled( field.itemNodes[ i ], true )
		end
	end


	function field:showList( state, offset )
		if state == nil then state = true end
		if offset == nil then offset = 0 end

		field.offsetList = offset

		local itemHeight = field:getItemHeight()
		local pos = gui.get_position( field.rootNode )
		pos.x = 0
		pos.y = offset * itemHeight
		gui.set_position( field.list, pos )
		
		gui.set_enabled( field.clip, state )
		gui.set_enabled( field.list, state )
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
	gui.set_size( field.clip, vmath.vector3( width, field.cntOpenItems * field:getItemHeight(), 1 ) )
	gui.set_enabled( field.clip, false )

	gui.set_id( field.list, id .. "/list" )
	gui.set_position( field.list, vmath.vector3( 4, 0, 0 ) )
	gui.set_enabled( field.list, false )
	
	gui.set_id( field.entryTmpl, id .. "/entry" )
	gui.set_position( field.entryTmpl, vmath.vector3( 0, 0, 0 ) )
	gui.set_enabled( field.entryTmpl, false )
	
	return field
end


return Selectbox
