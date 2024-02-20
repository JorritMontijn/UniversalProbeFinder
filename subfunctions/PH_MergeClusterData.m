function sClustMerged = PH_MergeClusterData(sClustKS,sClustTsv,boolSuppressWarning)
	%PH_MergeClusterData Merge cluster data entries by OrigIdx (sClustKS) and cluster_id (sClustTsv)
	%   sClustMerged = PH_MergeClusterData(sClustKS,sClustTsv,boolSuppressWarning)
	
	%check input
	if ~exist('boolSuppressWarning','var') || isempty(boolSuppressWarning)
		boolSuppressWarning = false;
	else
		boolSuppressWarning = boolSuppressWarning(1)>0;
	end
	
	%check id fields
	if isfield(sClustKS,'OrigIdx') && isfield(sClustTsv,'cluster_id')
		strFieldKsId = 'OrigIdx';
	elseif isfield(sClustKS,'cluster_id') && isfield(sClustTsv,'cluster_id')
		strFieldKsId = 'cluster_id';
	else
		error([mfilename ':NoId'],'Input is missing id field');
	end
	
	%replace all empty Ks ids with nan
	cellIdsKs = {sClustKS.(strFieldKsId)};
	vecEmptyKs = find(cellfun(@isempty,cellIdsKs));
	%cellIdsKs(vecEmptyKs) = cellfill(nan,size(vecEmptyKs));
	for i=vecEmptyKs(:)',sClustKS(i).(strFieldKsId) = nan;end
	vecIdsKs = [sClustKS.(strFieldKsId)];
	
	%replace all empty Tsv ids with nan
	cellIdsTsv = {sClustTsv.cluster_id};
	vecEmptyTsv = find(cellfun(@isempty,cellIdsTsv));
	%cellIdsTsv(vecEmptyTsv) = cellfill(nan,size(vecEmptyTsv));
	for i=vecEmptyTsv(:)',sClustTsv(i).cluster_id = nan;end
	vecIdsTsv = [sClustTsv.cluster_id];
	cellFields = fieldnames(sClustTsv);
	
	%merge cluster entries
	indAssignedKsEntries = false(size(sClustKS));
	sClustMerged = sClustKS;
	for intTsvEntry=1:numel(sClustTsv)
		%add missing ks entry
		intTsvId = sClustTsv(intTsvEntry).cluster_id;
		intKsEntry = find(vecIdsKs==intTsvId);
		if isempty(intKsEntry)
			intKsEntry = numel(sClustMerged)+1;
			sClustMerged(intKsEntry).OrigIdx = intTsvId;
		end
		indAssignedKsEntries(intKsEntry) = true;
		
		%add fields
		for intField=1:numel(cellFields)
			strField = cellFields{intField};
			sClustMerged(intKsEntry).(strField) = sClustTsv(intTsvEntry).(strField);
		end
	end
	
	%add missing tsv entries
	vecMissingEntriesInTsv = find(~indAssignedKsEntries);
	for intMissingTsvEntry=1:numel(vecMissingEntriesInTsv)
		intKsEntry = vecMissingEntriesInTsv(intMissingTsvEntry);
		sClustMerged(intKsEntry).cluster_id = sClustMerged(intKsEntry).(strFieldKsId);
	end
	
	%check numbers
	intMissingKsEntries = numel(indAssignedKsEntries) - numel(sClustKS);
	intMissingTsvEntries = numel(vecMissingEntriesInTsv);
	if ~boolSuppressWarning && (intMissingKsEntries ~= 0 || intMissingTsvEntries ~= 0)
		warning([mfilename ':MissingEntries'],'%d clusters present in ephys were missing in all .tsv files; %d clusters present in a .tsv file were missing from ephys\n',...
			intMissingTsvEntries,intMissingKsEntries);
		
		msgbox(sprintf('%d clusters present in ephys were missing in all .tsv files; \n%d clusters present in a .tsv file were missing from ephys',...
			intMissingTsvEntries,intMissingKsEntries),'Missing Entries');
	end
	
	%fill empty entries
	cellAllFields = fieldnames(sClustMerged);
	for intField=1:numel(cellAllFields)
		strField = cellAllFields{intField};
		cellColData = {sClustMerged.(strField)};
		indEmpty = cellfun(@isempty,cellColData);
		vecEmpty = find(indEmpty);
		indIsNumeric = cellfun(@isnumeric,cellColData);
		boolIsNumeric = all(indEmpty | indIsNumeric);
		for intEmpty=1:numel(vecEmpty)
			intTarget = vecEmpty(intEmpty);
			if boolIsNumeric
				sClustMerged(intTarget).(strField) = nan;
			else
				sClustMerged(intTarget).(strField) = '';
			end
		end
	end
end
