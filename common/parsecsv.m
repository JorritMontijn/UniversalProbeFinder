function cellVars = parsecsv(strLineCSV,strDelim)
	%parsecsv Parses CSV line. Syntax:
	%   cellVars = parsecsv(strLineCSV,strDelim)
	%
	%Version history:
	%1.0 - Nov 8 2019
	%	Created by Jorrit Montijn
	
	
	%get delimeter
	if ~exist('strDelim','var') || isempty(strDelim)
		strDelim = ',';
	end
	
	%get max # of vars & pre-allocate
	cellVars = cell(1,sum(strLineCSV==strDelim)+1);
	intVar = 1;
	intLinePos = 1;
	%get potential var boundaries
	indQuots = strLineCSV=='"';
	vecSingleQuotPos = (find([indQuots(3:end) == 0&indQuots(2:(end-1)) == 1&indQuots(1:(end-2)) == 0])+1);
	vecDelimPos = find(strLineCSV==strDelim);
	
	boolEnd = false;
	while ~boolEnd
		%save old pos
		intOldLinePos = intLinePos;
		
		if strcmp(strLineCSV(intLinePos),'"')
			%look for next single "
			intLinePos = vecSingleQuotPos(find(vecSingleQuotPos > intOldLinePos,1))+2;
			if isempty(intLinePos)
				intLinePos=numel(strLineCSV)+1;
				boolEnd=true;
			end
			if ~boolEnd && strLineCSV(intLinePos-1) ~= strDelim
				error([mfilename ':ParseError'],sprintf('Parsing error, pos %d should be delimeter [strLineCSV]\n',intLinePos-1,strLineCSV));
			end
			cellVars{intVar} = strLineCSV((intOldLinePos+1):(intLinePos-3));
		else
			%this var is until next delimeter
			intLinePos = vecDelimPos(find(vecDelimPos > intOldLinePos,1))+1;
			if isempty(intLinePos)
				intLinePos=numel(strLineCSV);
				boolEnd=true;
			end
			cellVars{intVar} = strLineCSV(intOldLinePos:(intLinePos-2));
		end
		intVar = intVar+1;
	end
	cellVars(intVar:end) = [];
end

