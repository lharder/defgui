local Form = require( "defgui.form" )


-- DefGUI -----------------------------------------
local Defgui = {}
function Defgui.createForm( id, nodenames )
	return Form.new( id, nodenames )
end


return Defgui


