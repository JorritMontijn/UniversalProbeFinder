function strFullField = PH_GetClusterField(sClusters,strFindField)
	%PH_GetClusterField Finds full field from abbreviated name
	%   strFullField = PH_GetClusterField(sClusters,strFindField)
	
	%remove prefixes
	strFullField='';
	if ~isstruct(sClusters);return;end
	cellFullProperties = fieldnames(sClusters);
	cellAbbrProperties = PH_RemPrefixes(cellFullProperties);

	for intField=1:numel(cellAbbrProperties)
		if strcmp(cellAbbrProperties{intField},strFindField) || strcmp(cellFullProperties{intField},strFindField)
			strFullField = cellFullProperties{intField};
		end
	end
end

