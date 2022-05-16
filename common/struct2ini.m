function strCharArray = struct2ini(structIn,strHeaderName)
	%struct2ini Transforms structure's fields to ini-type character array
	%    strCharArray = struct2ini(structIn,strHeaderName)
	
	strCharArray = '';
	
	intNum = numel(structIn);
	for intIdx=1:intNum
		if intNum == 1
			strIdx = '';
		else
			strIdx = ['(' num2str(intIdx) ')'];
		end
		
		strCharArray = strcat(strCharArray,'[',strHeaderName,strIdx,']','\n');
		cellFieldnames = fieldnames(structIn);
		for intField=1:numel(cellFieldnames)
			strField = cellFieldnames{intField};
			varVal = structIn(intIdx).(strField);
			if ischar(varVal)
				strVal=strcat('''',varVal,'''');
			elseif isnumeric(varVal) && isscalar(varVal)
				strVal=num2str(varVal);
			elseif isnumeric(varVal) && isvector(varVal)
				strVal=strcat('[',num2str(varVal(:)'),']');
			else
				warning([mfilename ':FieldIgnored'],sprintf('Field "%s" ignored due to incompatible data type',strField));
				continue;
			end
			strVarLine = strcat(strField,'=',strrep(strVal,'\','\\'),'\n');
			strCharArray = strcat(strCharArray,strVarLine);
		end
	end
end