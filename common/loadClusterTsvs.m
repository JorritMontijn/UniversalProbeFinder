function sClustTsv = loadClusterTsvs(strFolder,strSearchKey)
	%loadClusterTsvs Loads cluster .tsv files
	%   sClustTsv = loadClusterTsvs(strFolder,strSearchKey)
	%
	%Assigns data sClustTsv structure, indexing entries by the 'cluster_id' entry in the tsv file
	%strFolder can be a folder, or a structure output from dir()
	%strSearchKey can be a search key string
	
	%default search key
	if ~exist('strSearchKey','var') || isempty(strSearchKey)
		strSearchKey = 'cluster*.tsv';
	end
	
	%find all tsvs
	%strFolder='D:\Data\Raw\NoraUPF\RecIv2a1_2022-08-30R01_g0\RecIv2a1_2022-08-30R01_g0_imec0\kilosort';
	if ischar(strSearchKey) || islogical(strSearchKey)
		if ischar(strFolder) && exist(strFolder,'dir')
			sTsvs = dir(fullpath(strFolder,strSearchKey));
		elseif isstruct(strFolder) && isfield(strFolder,'folder')
			sTsvs = strFolder;
			strFolder = sTsvs(1).folder;
		else
			error([mfilename ':InputError'],'First input is not a folder and not a file structure');
		end
	else
		error([mfilename ':InputError'],'strSearchKey input is not search key');
	end
	
	%ask which ones to load
	if islogical(strSearchKey) && ~strSearchKey
		boolAccept = true;
		vecSelectIdx = 1:numel(sTsvs);
	else
		cellTsvs = {sTsvs.name};
		[vecSelectIdx,boolAccept] = listdlg('ListString',cellTsvs,'Name','Tsv selection','PromptString','Select .tsv files to load',...
			'OKString','Load','InitialValue',1:numel(cellTsvs));
	end
	if ~boolAccept || isempty(vecSelectIdx)
		vecSelectIdx = [];
		sClustTsv.cluster_id = [];
		sClustTsv(:) = [];
		return
	end
	
	%load
	cellFileName = cell(numel(vecSelectIdx),1);
	matEntryPresent = false(numel(vecSelectIdx),0);
	sClustTsv = struct;
	for intTsvIdx=1:numel(vecSelectIdx)
		intTsv = vecSelectIdx(intTsvIdx);
		[cellHeader,cellData]=tsvread(fullpath(strFolder,sTsvs(intTsv).name));
		cellFileName{intTsvIdx} = sTsvs(intTsv).name;
		
		%find cluster_id header column
		indClustIdCol = strcmpi(cellHeader,'cluster_id');
		intClustIdCol = find(indClustIdCol);
		intEntries = size(cellData,1);
		if isempty(intClustIdCol)
			warning([mfilename ':MissingId'],sprintf('Ignoring %s: it has no cluster_id column',sTsvs(intTsv).name));
			continue;
		else
			vecClustId = cellfun(@str2double,cellData(:,intClustIdCol));
		end
		
		%assign cluster ids
		if intTsvIdx==1
			for i=1:numel(vecClustId)
				sClustTsv(i).cluster_id = vecClustId(i);
			end
		end
		
		%assign all data
		vecDataCols = find(~indClustIdCol);
		for intColIdx=1:numel(vecDataCols)
			intCol = vecDataCols(intColIdx);
			strField = cellHeader{intCol};
			
			%check if column is numeric
			boolIsNumeric = false;
			cellColData = cellData(:,intCol);
			cellNumeric=regexp(cellColData,'^\d*[.]?\d*$');
			if ~any(cellfun(@isempty,cellNumeric))
				cellColData = cellfun(@str2double,cellColData,'uniformoutput',false);
				boolIsNumeric = true;
			end
			
			%loop through entries
			for i=1:intEntries
				intTarget = find([sClustTsv.cluster_id]==vecClustId(i));
				if isempty(intTarget)
					%add new entry
					warning([mfilename ':NewEntry'],sprintf('Adding cluster_id %d from file %s, which was not present in other tsv file(s)',...
						vecClustId(i),sTsvs(intTsv).name));
					intTarget = numel(sClustTsv)+1;
					sClustTsv(intTarget).cluster_id = vecClustId(i);
				end
				if isempty(cellColData{i})
					if boolIsNumeric
						sClustTsv(intTarget).(strField) = nan;
					else
						sClustTsv(intTarget).(strField) = '';
					end
				else
					sClustTsv(intTarget).(strField) = cellColData{i};
				end
				matEntryPresent(intTsvIdx,intTarget) = true;
			end
		end
	end
	
	%check missing entries
	vecEntries = sum(matEntryPresent,2);
	[vecEntryNumbers,ia,vecFileC]=unique(vecEntries);
	if numel(vecEntryNumbers) > 1
		warning([mfilename ':EntryNumberInconsistency'],'Number of clusters varies per file');
		for intEntryCount = 1:numel(vecEntryNumbers)
			intCount = vecEntryNumbers(intEntryCount);
			strWarn = sprintf('   Files with %d entries: ',intCount);
			vecFiles = find(vecFileC==intEntryCount);
			for intFile=1:numel(vecFiles)
				strWarn = [strWarn cellFileName{vecFiles(intFile)} ', '];
			end
			strWarn((end-1):end) = sprintf(' \n');
			fprintf(strWarn);
		end
	end
end