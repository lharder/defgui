require( "deflibs.defold" )
local lua = require( "deflibs.lualib" )

local Field = require( "defgui.field" )
local InputText = require( "defgui.txtfield" )
local Button = require( "defgui.button" )
local Checkbox = require( "defgui.checkbox" )
local Label = require( "defgui.label" )
local Selectbox = require( "defgui.selectbox" )
local Slider = require( "defgui.slider" )


-- Form -------------------------------------------
local Form = {}

function Form.new( id, nodenames )
	assert( id, "The form must have a unique id!" )
	assert( nodenames, "Please provide the names of nodes in your GUI to be used as templates for the different field types { button = 'btnNode', label = ... }!" )
	
	local form = {}
	form.id = id
	form.fields = {}
	form.nodes = {}

	-- disable template nodes: only use to be copied
	for fieldname, nodename in pairs( nodenames ) do
		form.nodes[ fieldname ] = guiGetNode( nodename )
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
	end

	
	function form:input( guiSelf, action_id, action )
		for id, field in pairs( form.fields ) do 
			field.inputHandler( guiSelf, field, action_id, action )
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

	
	function form:addSlider( id, x, y, handler, caption )
		local field = Slider.new( form, id, x, y, handler, caption )
		return field
	end
	

	function form:addLabel( id, x, y, width, height, handler, txt )
		local field = Label.new( form, id, x, y, width, height, handler, txt )
		return field
	end

	function form:addSelectbox( id, x, y, width, height, handler )
		local field = Selectbox.new( form, id, x, y, width, height, handler )
		return field
	end

	function form:fade( opacity, secs, callback )
		if secs == nil then secs = 1 end
		for name, field in pairs( form.fields ) do
			gui.animate( field.rootNode, "color.w", opacity, gui.EASING_LINEAR, secs, 0, function() 
				if callback then callback() end
			end, gui.PLAYBACK_ONCE_FORWARD )
		end
	end

	function form:fadeout( secs, callback )
		form:fade( 0, secs, callback )
	end

	function form:fadein( secs, callback )
		form:fade( 1, secs, callback )
	end
	

	return form
end


return Form

