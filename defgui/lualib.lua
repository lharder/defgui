local lua = {}

function lua.approximates( value, compare, range )
	return ( value >= compare - range ) and ( value <= compare + range )
end


function lua.randomize()
	math.randomseed( socket.gettime() )
	math.random(); math.random(); math.random()
end

function lua.length( t )
	if t == nil then return 0 end
	
	local count = 0
	for _ in pairs( t ) do count = count + 1 end
	return count
end

--[[ 
-- https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
HighScore = { Robin = 8, Jon = 10, Max = 11 }

-- basic usage, just sort by the keys
for k,v in spairs(HighScore) do
	print(k,v)
end
--> Jon     10
--> Max     11
--> Robin   8

-- this uses an custom sorting function ordering by score descending
for k,v in spairs(HighScore, function(t,a,b) return t[b] < t[a] end) do
	print(k,v)
end
--> Max     11
--> Jon     10
--> Robin   8
--]]
function lua.spairs( t, order )
	-- collect the keys
	local keys = {}
	for k in pairs( t ) do keys[ #keys + 1 ] = k end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys 
	if order then
		table.sort( keys, function( a, b ) return order( t, a, b ) end )
	else
		table.sort( keys )
	end

	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[ i ] then
			return keys[ i ], t[ keys[ i ] ]
		end
	end
end



function lua.round( num )
	return math.floor( num + .5 )
end


function lua.contains( tab, value )
	for key, item in pairs( tab ) do
		if item == value then
			return true
		end
	end

	return false
end


function lua.concat( t1, t2 )
	for _, v in ipairs( t2 ) do 
		table.insert( t1, v )
	end

	return t1
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


function lua.deepcopy( obj )
	if type( obj ) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs( obj ) do res[ lua.deepcopy( k ) ] = lua.deepcopy( v ) end

	return res
end


function lua.removeFromList( arr, value )
	local arr_size = #arr
	local i = 1
	while i <= arr_size do
		if arr[ i ] == value then
			arr[ i ] = arr[ arr_size ]
			arr[ arr_size ] = nil
			arr_size = arr_size - 1
		else
			i = i + 1
		end
	end
end


return lua