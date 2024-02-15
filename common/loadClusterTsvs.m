function sClustTsv = loadClusterTsvs(strFolder,strSearchKey)
	%loadClusterTsvs Loads cluster .tsv files
	%   sClustTsv = loadClusterTsvs(strFolder,strSearchKey)
	%
	%Assigns data sClustTsv structure, indexing entries by the 'cluster_id' entry in the tsv file
	
	%default search key
	if ~exist('strSearchKey','var') || isempty(strSearchKey)
		strSearchKey = 'cluster*.tsv';
	end
	
	%find all tsvs
	%strFolder='D:\Data\Raw\NoraUPF\RecIv2a1_2022-08-30R01_g0\RecIv2a1_2022-08-30R01_g0_imec0\kilosort';
	sTsvs = dir(fullpath(strFolder,strSearchKey));
	sClustTsv = struct;
	for intTsv=1:numel(sTsvs)
		[cellHeader,cellData]=tsvread(fullpath(strFolder,sTsvs(intTsv).name));
		
		%find cluster_id header column
		indClustIdCol = strcmpi(cellHeader,'cluster_id');
		intClustIdCol = find(indClustIdCol);
		intEntries = size(cellData,1);
		if isempty(intClustIdCol)
			vecClustId = 1:intEntries;
		else
			vecClustId = cellfun(@str2double,cellData(:,intClustIdCol));
		end
		
		%assign cluster ids
		if intTsv==1
			for i=1:numel(vecClustId)
				sClustTsv(i).cluster_id = vecClustId(i);
			end
		end
		
		%check if entries exist for all clusters
		if intEntries < numel(sClustTsv)
			warning([mfilename ':MissingEntries'],sprintf('File %s has %d clusters, while previous file(s) had %d',...
				sTsvs(intTsv).name,intEntries,numel(sClustTsv)));
		end
		
		%assign all data
		vecDataCols = find(~indClustIdCol);
		for intColIdx=1:numel(vecDataCols)
			intCol = vecDataCols(intColIdx);
			strField = cellHeader{intCol};
			
			%check if column is numeric
			cellColData = cellData(:,intCol);
			cellNumeric=regexp(cellColData,'^\d*[.]?\d*$');
			if ~any(cellfun(@isempty,cellNumeric))
				cellColData = cellfun(@str2double,cellColData,'uniformoutput',false);
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
				sClustTsv(intTarget).(strField) = cellColData{i};
			end
		end
	end
end

