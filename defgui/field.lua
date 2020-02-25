require( "defgui.stringutils" )

local lua = require( "defgui.lualib" )


-- Field -------------------------------------------
local Field = {}

function Field.new( id, x, y, width, height, handler )
	local field = {}
	field.id = id
	field.x = x
	field.y = y
	field.width = width
	field.height = height
	field.hasFocus = false
	field.colors = {}
	field.inputHandler = handler or function() pprint( "No input handler defined for field " .. id ) end

	
	function field:focus( onOff )
		if onOff == nil then onOff = true end
		field.hasFocus = onOff

		if field.hasFocus then
			-- call optional focusReceivedHandler of this field
			ok, result = pcall( field.onFocusReceived )

			-- take away focus from any other field in the form!
			for id, formfield in pairs( field.form.fields ) do
				if formfield.id ~= field.id then
					formfield:focus( false )
				end
			end
		else 
			-- call optional focusLostHandler of this field
			ok, result = pcall( field.onFocusLost )
		end
	end


	function field:setColor( name, value )
		assert( name, "Color name must not be nil!" )
		assert( value, "Color value must not be nil!" )

		if type( value ) == "string" then
			if value:startsWith( "#" ) then 
				value = value:sub( 2 )
			end
			value = Color( value, 1 )
		end

		field.colors[ name ] = value
	end


	function field:getColor( name )
		return field.colors[ name ]
	end


	function field:setScale( factor )
		assert( factor, "Scaling factor must not be nil!" )

		if type( factor ) == "number" then 
			gui.set_scale( field.rootNode, vmath.vector3( factor, factor, factor ) )
		else
			gui.set_scale( field.rootNode, factor )
		end
	end
	

	return field
end


return Field