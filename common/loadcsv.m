function sData = loadcsv(strFile,strDelim,boolTransform)
	%loadcsv Loads CSV file. Syntax:
	%   sData = loadcsv(strFile,strDelim,boolTransform)
	%
	%Inputs:
	%	strFile: file location
	%	strDelim: delimeter (default: ,)
	%	boolTransform: boolean; transform data to numeric (default:true)
	%
	%Output:
	%	sData: structure where each field is a variable in the csv file
	%
	%This function automatically transforms numeric variables to doubles.
	%All other data is supplied as a cell array. Uses subfunction parsecsv.
	%
	%Version history:
	%1.0 - Nov 8 2019
	%	Created by Jorrit Montijn
	
	%get delimeter
	if ~exist('strDelim','var') || isempty(strDelim)
		strDelim = ',';
	end
	
	%get boolTransform
	if ~exist('boolTransform','var') || isempty(boolTransform)
		boolTransform = true;
	end
	
	%open file
	ptrFile = fopen(strFile,'r');
	strLineCSV = fgetl(ptrFile);
	
	%pre-allocate output
	intAddEntries=10000;
	intTotalEntries = intAddEntries;
	intCounter = 0;
	sData = struct;
	cellVars = parsecsv(strLineCSV,strDelim);
	if ~ischar(cellVars{1})
		strLine = '"Time","VidFrame","SyncLum","SyncPulse","CenterX","CenterY","MajorAx","MinorAx","Orient","Eccentric","Roundness"';
		cellVars = parsecsv(strLine);
	end
	for intVar=1:numel(cellVars)
		sData.(cellVars{intVar}) = cell(intAddEntries,1);
	end
	
	%read
	while 1
		intCounter = intCounter + 1;
		%allocate more entries
		if intCounter > intTotalEntries
			intTotalEntries = intTotalEntries+intAddEntries;
			for intVar=1:numel(cellVars)
				sData.(cellVars{intVar}) = cat(1,sData.(cellVars{intVar}),cell(intAddEntries,1));
			end
		end
		%get data
		strLineCSV = fgetl(ptrFile);
		%check end of file
		if strLineCSV == -1
			break;
		end
		%assign data
		cellVarData = parsecsv(strLineCSV,strDelim);
		for intVar=1:numel(cellVarData)
			sData.(cellVars{intVar}){intCounter} = cellVarData{intVar};
		end
	end
	%remove additional entries & transform to numeric if possible
	for intVar=1:numel(cellVarData)
		sData.(cellVars{intVar})(intCounter:end) = [];
		%transform to numeric if possible
		if boolTransform
			vecData=cellfun(@str2double,sData.(cellVars{intVar}));
			%check if data is numeric
			if all(strcmpi(sData.(cellVars{intVar})(isnan(vecData)),'nan'))
				sData.(cellVars{intVar}) = vecData;
			end
		end
	end
	
	%close file
	fclose(ptrFile);
end

