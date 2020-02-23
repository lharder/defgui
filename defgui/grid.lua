local lua = require( "defgui.lualib" )


local Grid = {}

function Grid.new( form, id, left, top, width, height, columns, rows )
	local grid = {}
	grid.form = form
	grid.id = id
	grid.top = top
	grid.left = left
	grid.width = width
	grid.height = height
	grid.columns = columns or 1
	grid.rows = rows or 1
	grid.fields = {}

	function grid:getNextPos()
		local colSpace = grid.width / grid.columns
		local rowSpace = grid.height / grid.rows

		local cnt = lua.length( grid.fields )
		local row = math.floor( cnt / grid.columns )
		local col = cnt % grid.columns

		local xPos = grid.left + col * colSpace
		local yPos = grid.top  - row * rowSpace

		return xPos, yPos
	end


	function grid:addCheckbox( id, handler, caption )
		local x, y = grid:getNextPos()
		local field = grid.form:addCheckbox( id, x, y, handler, caption )

		grid.fields[ id ] = field
		return field		
	end


	function grid:addLabel( id, width, height, handler, txt )
		local x, y = grid:getNextPos()
		local field = grid.form:addLabel( id, x, y, width, height, handler, txt )

		grid.fields[ id ] = field
		return field		
	end


	function grid:addButton( id, width, height, handler, caption )
		local x, y = grid:getNextPos()
		local field = grid.form:addButton( id, x, y, width, height, handler, caption )

		grid.fields[ id ] = field
		return field	
	end


	function grid:addTextField( id, width, height, handler, defaultValue )
		local x, y = grid:getNextPos()
		local field = grid.form:addTextField( id, x, y, width, height, handler, defaultValue )

		grid.fields[ id ] = field
		return field	
	end
	
	
	return grid
end


return Grid