function [strOut,intStop,intStart] = getFlankedBy(strInput,strBefore,strAfter,strWhich)
	%getFlankedBy Returns string flanked by two other strings
	%Syntax: [strOut,intStop,intStart] = getFlankedBy(strInput,strBefore,strAfter,strWhich)
	%
	%	Version history:
	%	1.0 - August 6 2013
	%	Created by Jorrit Montijn
	%	1.1 - April 2 2019
	%	Added option for 'last', and added intStart output argument [by JM]
	
	if ~exist('strWhich','var') || isempty(strWhich)
		strWhich = 'first';
	end
	
	intStop = -1;
	strOut = '';
	vecStart = strfind(strInput,strBefore);
	if ~isempty(vecStart) || isempty(strBefore)
		if isempty(strBefore)
			intStart = 1;
		else
			if strcmp(strWhich,'last')
				intStart = vecStart(end) + length(strBefore);
			elseif strcmpi(strWhich,'first')
				intStart = vecStart(1) + length(strBefore);
			end
		end
		findLast = strfind(strInput,strAfter);
		if ~isempty(findLast) || isempty(strAfter)
			if isempty(strAfter)
				intStop = length(strInput) + 1;
			else
				intStop = findLast(find(strfind(strInput,strAfter) > intStart,1,strWhich));
			end
			if ~isempty(intStop)
				strOut = strInput(intStart:(intStop-1));
			end
		end
	end
end

