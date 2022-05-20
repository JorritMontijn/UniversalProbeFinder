function matData = DP_FindMins(matData, vecBinN, vecFiltDims, intType)
	%DP_FindMins Returns running minimum across requested dimensions
	%	matData = DP_FindMins(matData, vecBinN, vecFiltDims, intType)
	%
	%input:
	% - matData [Ch x T]: gpuArray [Channel by Timepoint] data matrix
	% - vecBinN:		vector of bin size per filter dimension
	% - vecFiltDims:		vector of dimensions to filter
	% - intType:	switch to use slow, but high-precision procedure (intType=2) 
	%				or fast (50% reduction), but approximate procedure (default, intType=1)
	%
	%output:
	% - matData; filtered data
	%
	%Based on Kilosort2's gpufilter.m
	%
	%Version history:
	%1.0 - 6 Dec 2019
	%	Created by Jorrit Montijn
	
	%check inputs
	if ~exist('vecFiltDims','var') || isempty(vecFiltDims)
		vecFiltDims = 2;
	end
	if numel(vecFiltDims) ~= numel(vecBinN)
		vecBinN = repmat(vecBinN, numel(vecFiltDims), 1);
	end
	if ~exist('intType','var') || isempty(intType)
		intType = 1;
	end
	
	for i = 1:length(vecFiltDims)
		intBinN = vecBinN(i);
		objSE = strel('line',intBinN*2,0);
		
		intFiltDim = vecFiltDims(i);
		intDimsData = ndims(matData);
		
		%rearrange dimensions such that the current dimension to run is #1
		matData = permute(matData, [intFiltDim 1:(intFiltDim-1) (intFiltDim+1):intDimsData]);
			
		if intType == 1
			%fast, rather accurate (close to type 2)
			vecMins = min(matData,[],1);
			vecMaxs = max(matData,[],1);
			matData = uint8(256*bsxfun(@rdivide,bsxfun(@minus,matData,vecMins),vecMaxs-vecMins));
			matData = imerode(matData',objSE)';
			matData = bsxfun(@plus,bsxfun(@mtimes,(single(matData)/256),vecMaxs-vecMins),vecMins);
		else
			%slow, most accurate
			vecNewSize = size(matData);
			matData = reshape(matData, size(matData,1), []);
			vecNewSize2 = size(matData);
			
			matData = cat(1, Inf*ones([intBinN, vecNewSize2(2)]),matData, Inf*ones([intBinN, vecNewSize2(2)])); %pad with infs
			%introduce offset between two matrices
			Smax = matData(1:vecNewSize2(1), :);
			%loop through offset steps to compute vectorized minimum
			for j = 1:2*intBinN
				Smax = min(Smax, matData(j + (1:vecNewSize2(1)), :));
			end
			matData = reshape(Smax, vecNewSize);
		end
		
		matData = permute(matData, [2:intFiltDim 1 intFiltDim+1:intDimsData]);
	end
end