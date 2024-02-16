function cellAllProperties = PH_RemPrefixes(cellAllProperties)
	%PH_RemPrefixes Remove prefixes
	%   cellAllProperties = PH_RemPrefixes(cellAllProperties)
	
	cellRemPrefix = {'dbl','vec','str'};
	for i=1:numel(cellAllProperties)
		for j=1:numel(cellRemPrefix)
			if numel(cellAllProperties{i}) > numel(cellRemPrefix{j}) && strcmp(cellAllProperties{i}(1:numel(cellRemPrefix{j})),cellRemPrefix{j})
				cellAllProperties{i} = cellAllProperties{i}(4:end);
			end
		end
	end
end

