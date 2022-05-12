function [cellStructs,cellStructNames] = ini2struct(strData)
	%ini2struct Transforms ini-type character array to a structure's fields
	%    [structOut,strStructName] = ini2struct(strData)
	
	%pre-allocate
	cellStructs = {};
	cellStructNames = {};
	intCurStruct = 0;
	%run
	cellLines = strsplit(strData,newline);
	for intLine=1:numel(cellLines)
		strLine = cellLines{intLine};
		%check if new structure
		if isempty(strLine),continue;
		elseif strcmp(strLine(1),'[') && ~isempty(getFlankedBy(strLine,'[',']'))
			intCurStruct = intCurStruct + 1;
			cellStructs{intCurStruct} = struct;
			cellStructNames{intCurStruct} = getFlankedBy(strLine,'[',']');
		elseif contains(strLine,'=')
			vecIsLoc = strfind(strLine,'=');
			strField = strLine(1:(vecIsLoc(1)-1));
			strValue = strLine((vecIsLoc(1)+1):end);
			cellStructs{intCurStruct}.(strField) = eval(strcat(strValue,';'));
		else
			warning([mfilename ':WrongSyntax'],sprintf('Line %d not recognized: %s',intLine,strLine));
		end
	end
end

