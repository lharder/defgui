local lua = {}

function lua.randomize()
	math.randomseed( os.time() )
	math.random(); math.random(); math.random()
end

function lua.length( t )
	local count = 0
	for _ in pairs( t ) do count = count + 1 end
	return count
end


function lua.contains( tab, value )
	for key, item in pairs( tab ) do
		if item == value then
			return true
		end
	end

	return false
end


function lua.keys( tab )
	local ks = {}
	local n = 0
	for key, value in pairs( tab ) do
		n = n + 1
		ks[ n ] = key
	end

	return ks
end


function lua.guiGetNode( id )
	local ok, result = pcall( gui.get_node, id )
	if ok then 
		return result
	else
		pprint( "Error: " .. result ) 
	end
end



return lua