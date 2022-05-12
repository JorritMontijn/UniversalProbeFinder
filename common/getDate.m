function strDate = getDate()
	%UNTITLED3 Summary of this function goes here
	%   Detailed explanation goes here
	
	vecDate = fix(clock);
	strDate = sprintf('%02d-%02d-%02d',vecDate(1:3));
end

