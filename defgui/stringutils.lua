string.split = function( s, delim )
	local fields = {}
	local pattern = string.format( "([^%s]+)", delim )
	s:gsub( pattern, 
		function( c ) 
			fields[ #fields + 1 ] = c 
		end 
	)

	return fields
end


string.startsWith = function( s, start )
	return s:sub( 1, #start ) == start
end


string.endsWith = function( s, ending )
	return ending == "" or s:sub(-#ending) == ending
end


string.indexOf = function( s, txt, startAtPos )
	if startAtPos == nil then startAtPos = 0 end

	-- returns two values: start and end position!
	local start, stop = string.find( s, txt, startAtPos, true )
	if start then 
		return start 
	else
		return -1
	end
end


string.lastIndexOf = function( haystack, needle )
	if needle == "." then needle = "%." end
	local i = haystack:match(".*"..needle.."()")
	if i == nil then return nil else return i - 1 end
end


string.between = function( s, strStart, strEnd, isExcluded )
	local pos01 = s:indexOf( strStart )
	if pos01 == nil then return nil end

	local pos02 = s:indexOf( strEnd, pos01 )
	if pos02 == nil then return nil end

	local res = s:sub( pos01, pos02 )
	if isExcluded then 
		if res:len() < 2 then return "" end
		return res:sub( 2, res:len() - 1 )
	else
		return res 
	end
end


string.cntSubstr = function( s1, s2 )
	if s2 == nil then return 0 end
	if s2 == "." then s2 = "%." end

	return select( 2, s1:gsub( s2, "" ) )
end


string.substr = function( str, pos01, pos02 )
	return string.sub( str, pos01, pos02 )
end



-- StringBuilder-----------------------------
-- build strings efficiently
StringBuilder = {}
function StringBuilder.new( txt )
	local sb = {}
	sb.strings = {}

	function sb:append( txt )
		table.insert( sb.strings, txt )
		return sb
	end

	function sb:remove( index )
		if index == nil then 
			table.remove( sb.strings )
		else
			table.remove( sb.strings, index )
		end
	end

	function sb:toString()
		table.insert( sb.strings, "" )
		return table.concat( sb.strings )
	end

	-- initial value?
	if txt ~= nil then 
		sb:append( txt )
	end

	return sb
end
