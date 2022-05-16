function [varDataOut,vecUnique,vecCounts,cellSelect,vecRepetition] = val2idx(varData)
	%val2idx Transforms label-entries to consecutive integer-based data
	%Syntax: [varDataOut,vecUnique,vecCounts,cellSelect,vecRepetition] = val2idx(varData)
	%
	%Used to be label2idx, but matlab now has a built-in with that name..
	
	varDataOut = nan(size(varData));
	vecUnique = unique(varData);
	vecCounts = zeros(size(vecUnique));
	vecIdx = 1:length(vecUnique);
	cellSelect = cell(1,length(vecUnique));
	vecRepetition = zeros(1,length(vecUnique));
	if iscell(vecUnique)
		%character array
		for intIdx=vecIdx
			indEntries = strcmp(varData,vecUnique{intIdx});
			cellSelect{intIdx} = indEntries;
			varDataOut(indEntries) = intIdx;
			vecCounts(intIdx) = sum(indEntries(:));
			vecRepetition(indEntries) = 1:sum(indEntries(:));
		end
	else
		%numeric vector
		for intIdx=vecIdx
			indEntries = varData==vecUnique(intIdx);
			cellSelect{intIdx} = indEntries;
			varDataOut(indEntries) = intIdx;
			vecCounts(intIdx) = sum(indEntries(:));
			vecRepetition(indEntries) = 1:sum(indEntries(:));
		end
	end
end

