local lua = require( "defgui.lualib" )
local Field = require( "defgui.field" )


-- InputText -------------------------------------------
local InputText = {}

function InputText.new( form, id, x, y, width, height, handler, defaultValue )
	local inputTxtHandler = function( guiSelf, field, action_id, action )
		if action_id == hash( "touch" ) and action.pressed then 

			if gui.pick_node( field.rootNode, action.x, action.y ) then
				field:focus()

				local rootPos = gui.get_position( field.rootNode )
				field:placeCursor( action.x - rootPos.x )
			end

		elseif action_id == hash( "left" ) and field.hasFocus then
			if socket.gettime() > field.timeNextKeyIsOk then
				field.timeNextKeyIsOk = socket.gettime() + field.keystrokeCooldownTime

				local cursorPos = gui.get_position( field.cursorNode )
				if cursorPos.x >= 2 then field:placeCursor( cursorPos.x - field.charWidth ) end
			end

		elseif action_id == hash( "right" ) and field.hasFocus then
			if socket.gettime() > field.timeNextKeyIsOk then
				field.timeNextKeyIsOk = socket.gettime() + field.keystrokeCooldownTime

				local cursorPos = gui.get_position( field.cursorNode )
				if cursorPos.x < field.width - field.charWidth then field:placeCursor( cursorPos.x + field.charWidth ) end
			end

		elseif action_id == hash( "text" ) and field.hasFocus then 
			if socket.gettime() > field.timeNextKeyIsOk then
				field.timeNextKeyIsOk = socket.gettime() + field.keystrokeCooldownTime

				local cursorPos = gui.get_position( field.cursorNode )
				local txtWidth = field:textSize( field.value ).width
				if txtWidth < field.width - field.charWidth then

					local index = field.insertNextCharAt
					local left = field.value:sub( 1, index )
					local right = field.value:sub( index + 1 )
					field.value = left .. action.text .. right 

					gui.set_text( field.txtNode, field.value )

					field.insertNextCharAt = field.insertNextCharAt + 1
					field:placeCursor( cursorPos.x + field.charWidth )
				end
			end

		elseif action_id == hash( "backspace" ) and field.hasFocus then
			if socket.gettime() > field.timeNextKeyIsOk then
				field.timeNextKeyIsOk = socket.gettime() + field.keystrokeCooldownTime

				local leftTxt, leftTxtWidth = field:getTxtLeftOfCursor()
				if not leftTxt then leftTxt = "" end
				if #leftTxt > 0 then
					local left = field.value:sub( 1, #leftTxt - 1 )
					local right = field.value:sub( #leftTxt + 1 )
					field.value = left .. right

					gui.set_text( field.txtNode, field.value )

					local txtWidth = field:textSize( left ).width
					field:placeCursor( txtWidth )
				end
			end
		end

		-- call users custom input listener if provided
		if handler then
			local ok, errMsg = pcall( handler, guiSelf, field, action_id, action )
			if not ok then pprint( "Custom input handler of field " .. field.id .. " caused error: " .. errMsg ) end
		end

	end

	local field = Field.new(  id, x, y, width, height, inputTxtHandler )
	field.value = defaultValue or ""
	field.timeNextKeyIsOk = socket.gettime()
	field.keystrokeCooldownTime = 0.15
	field.insertNextCharAt = 1
	field.charWidth = 12					-- width of a single character in the given font: may be changed!


	local tmplNode = lua.guiGetNode( "txtfield/root" )
	assert( tmplNode, "You must have a node in your GUI which must be declared as a template for textfields in your form!" )

	local nodes = gui.clone_tree( tmplNode )

	field.rootNode = nodes[ hash( "txtfield/root" ) ]
	assert( field.rootNode, "Unable to access newly created txtfield/root node!" )

	gui.set_id( field.rootNode, id .. "/root" )
	gui.set_position( field.rootNode, vmath.vector3( x, y, 1 ) )
	gui.set_size( field.rootNode, vmath.vector3( width, height, 1 ) )
	gui.set_enabled( field.rootNode, true )

	field.txtNode = nodes[ hash( "txtfield/text" ) ]
	assert( field.txtNode, "Unable to access newly created txtfield/text node!" )

	gui.set_id( field.txtNode, id .. "/text" )
	gui.set_text( field.txtNode, field.value ) 
	gui.set_enabled( field.txtNode, true )

	field.cursorNode = nodes[ hash( "txtfield/cursor" ) ]
	assert( field.cursorNode, "Unable to access newly created txtfield/cursor node!" )

	gui.set_id( field.cursorNode, id .. "/cursor" )
	gui.set_enabled( field.cursorNode, false )
		
	form:add( field )


	function field:textSize( txt )
		if txt == nil then txt = field.value end
		return nodeTextSize( field.txtNode, txt )
	end


	function field:getTxtLeftOfCursor()
		local cursorPos = gui.get_position( field.cursorNode )

		-- if click is to the very left, do not(!) enter loop even once...
		if cursorPos.x < field:textSize( "-" ).width then return "", 0 end
		
		local leftTxt
		local txtWidth
		local leftTxtWidth
		local noOfChar
		for i = 1, #field.value do
			leftTxt = field.value:sub( 1, i )
			txtWidth = field:textSize( leftTxt ).width
			if txtWidth > cursorPos.x then 
				noOfChar = i - 1
				break 
			end
			leftTxtWidth = txtWidth
		end

		if leftTxtWidth then 
			return field.value:sub( 1, noOfChar ), leftTxtWidth
		end
	end


	function field:placeCursor( clickPosX )
		local cursorPos = gui.get_position( field.cursorNode )
		if clickPosX then 
			cursorPos.x = clickPosX 
			gui.set_position( field.cursorNode, cursorPos )
		end

		local leftTxt, leftTxtWidth = field:getTxtLeftOfCursor()
		if leftTxtWidth then 
			cursorPos.x = leftTxtWidth
			-- pprint( leftTxt )

			field.insertNextCharAt = #leftTxt
		end
		gui.set_position( field.cursorNode, cursorPos )

		return field.cursorNode
	end



	function field:onFocusReceived()
		gui.set_enabled( field.cursorNode, true )

		if field.cursorTimer then timer.cancel( field.cursorTimer ) end
		field.cursorTimer = timer.delay( .4, true, 
			function()  
				gui.set_enabled( field.cursorNode, not gui.is_enabled( field.cursorNode ) )
			end 
		)
	end


	function field:onFocusLost()
		timer.cancel( field.cursorTimer )
		gui.set_enabled( field.cursorNode, false )
	end


	function field:setColorText( color )
		field:setColor( "text", color )
		gui.set_color( field.txtNode, field:getColor( "text" ) )
	end


	function field:setColorBG( color )
		field:setColor( "background", color )
		gui.set_color( field.rootNode, field:getColor( "background" ) )
	end


	function field:setColorCursor( color )
		field:setColor( "cursor", color )
		gui.set_color( field.cursorNode, field:getColor( "cursor" ) )
	end


	function field:setFont( fontname )
		gui.set_font( field.txtNode, fontname )
		gui.set_font( field.cursorNode, fontname )

		-- need to adjust reference width of chars
		field.charWidth = field:textSize( "o" ).width
	end
	


	function field:setText( txt )
		field.value = txt
		gui.set_text( field.txtNode, field.value ) 
	end


	-- set reference width of chars. "o" is random.
	field.charWidth = field:textSize( "o" ).width
	field:placeCursor()

	return field
end


return InputText