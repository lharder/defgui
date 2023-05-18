require( "defgui.utils" )

-- local lua = require( "deflibs.lualib" )
local Field = require( "defgui.field" )


-- Label --------------------------------------------------
local Label = {}

function Label.new( form, id, x, y, width, height, handler, txt )
	local clickHandler = function( guiSelf, field, action_id, action )
		if guiIsClicked( field.rootNode, action_id, action ) then 
			if handler then 
				handler( guiSelf, field, action_id, action )
			end
		end
	end


	local field = Field.new( id, x, y, width, height, clickHandler )

	local tmplNode = guiGetNode( "label/root" )
	assert( tmplNode, "You must have a node in your GUI which must be declared as a template for labels in your form!" )

	local nodes = gui.clone_tree( tmplNode )

	field.rootNode = nodes[ hash( "label/root" ) ]
	assert( field.rootNode, "Unable to access newly created label/root node!" )

	gui.set_id( field.rootNode, id .. "/root" )
	gui.set_position( field.rootNode, vmath.vector3( x, y, 1 ) )
	gui.set_size( field.rootNode, vmath.vector3( width, height, 1 ) )
	gui.set_enabled( field.rootNode, true )

	form:add( field )


	function field:textSize( txt )
		if txt == nil then txt = field.value end
		return nodeTextSize( field.rootNode, txt )
	end


	function field:setText( txt )
		field.value = txt

		-- text fits in label width, no problem
		if field:textSize( txt ).width < field.width then 
			gui.set_text( field.rootNode, field.value )
			return 
		end

		-- text is wider than label: add breaks at proper positions
		local breakPos = 0
		local lines = {}
		local i = 1
		local lastChar

		while field:textSize( txt ).width > field.width do
			local line = txt:sub( 1, i )

			while field:textSize( line ).width < field.width do
				i = i + 1
				line = txt:sub( 1, i )

				lastChar = txt:sub( i, i )
				if lastChar == " " or lastChar == "\n" then 
					breakPos = i
				end
			end
			if breakPos == 0 then breakPos = i end 		-- word too long, no break option found!
			line = txt:sub( 1, breakPos - 1 )
			table.insert( lines, line )

			txt = txt:sub( breakPos + 1 )			
			breakPos = 0
			i = 1
		end
		table.insert( lines, txt )

		local display = table.concat( lines, "\n" ) 
		gui.set_text( field.rootNode, display )
	end


	function field:setColorText( color )
		field:setColor( "text", color )
		gui.set_color( field.rootNode, field:getColor( "text" ) )
	end


	function field:setFont( fontname )
		gui.set_font( field.rootNode, fontname )
	end


	field:setText( txt )
	return field
end


return Label