local lua = require( "defgui.lualib" )

local Field = require( "defgui.field" )
local InputText = require( "defgui.txtfield" )
local Button = require( "defgui.button" )
local Checkbox = require( "defgui.checkbox" )
local Label = require( "defgui.label" )
local Grid = require( "defgui.grid" )


-- Form -------------------------------------------
local Form = {}

function Form.new( id, nodenames )
	assert( id, "The form must have a unique id!" )
	assert( nodenames, "Please provide the names of nodes in your GUI to be used as templates for the different field types { button = 'btnNode', label = ... }!" )
	
	local form = {}
	form.id = id
	form.fields = {}
	form.nodes = {}
	form.grids = {}

	-- disable template nodes: only use to be copied
	for fieldname, nodename in pairs( nodenames ) do
		form.nodes[ fieldname ] = lua.guiGetNode( nodename )
		if form.nodes[ fieldname ] then 
			gui.set_enabled( form.nodes[ fieldname ], false )
		end
	end

	
	function form:add( field )
		assert( field, "Form field must not be nil!" )
		assert( field.id, "Form field must have an id!" )
		assert( not lua.contains( form.fields, field.id ), "Duplicate field id: " .. field.id .. " in form!" )

		form.fields[ field.id ] = field
		field.form = form

		function form:input( guiSelf, action_id, action )
			for id, field in pairs( form.fields ) do 
				field.inputHandler( guiSelf, field, action_id, action )
			end
		end
	end


	function form:addTextField( id, x, y, width, height, handler, defaultValue )
		local field = InputText.new( form, id, x, y, width, height, handler, defaultValue )
		return field
	end


	function form:addButton( id, x, y, width, height, handler, caption )
		local field = Button.new( form, id, x, y, width, height, handler, caption )
		return field
	end


	function form:addCheckbox( id, x, y, handler, caption )
		local field = Checkbox.new( form, id, x, y, handler, caption )
		return field
	end

	function form:addLabel( id, x, y, width, height, handler, txt )
		local field = Label.new( form, id, x, y, width, height, handler, txt )
		return field
	end

	function form:addGrid( id, x, y, width, height, columns, rows )
		local grid = Grid.new( form, id, x, y, width, height, columns, rows )
		form.grids[ id ] = grid
		
		return grid
	end

	function form:getGrid( id )
		return form.grids[ id ]
	end
	

	return form
end


return Form

