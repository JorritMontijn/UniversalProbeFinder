function matData = DP_gpufilter(matData, b, a, intCAR)
	%DP_gpufilter Performs fast GPU-accelerated filtering
	%	matData = DP_gpufilter(matData, b1, a1, intCAR)
	%
	%input:
	% - matData [Ch x T]: gpuArray [Channel by Timepoint] data matrix
	% - b:		transfer function coefficient b (see butter.m )
	% - a:		transfer function coefficient a (see butter.m )
	% - intCAR:	switch for common average rereferencing; 0=off,1=mean,2=median (default: 1)
	%
	%output:
	% - matData; filtered data
	%
	%Based on Kilosort2's gpufilter.m
	%
	%Version history:
	%1.0 - 5 Dec 2019
	%	Created by Jorrit Montijn
	
	%check if gpuarray
	if ~existsOnGPU(matData)
		warning([mfilename ':DataNotOnGPU'],'Supplied data was non-GPU, transferring now...');
		matData = gpuArray(matData);
	end
	
	%transpose & convert
	matData = matData';
	matData = single(matData); % convert to float32 so GPU operations are fast
	
	% subtract the mean from each channel
	matData = matData - mean(matData, 1); % subtract mean of each channel
	
	% CAR, common average referencing by median
	if exist('intCAR','var') && intCAR
		%mean is MUCH faster than median, and usually not much worse than the median
		if intCAR == 2
			matData = matData - median(matData, 2); % subtract median across channels
		else
			matData = matData - mean(matData, 2); % subtract mean across channels
		end
	end
	
	% next four lines should be equivalent to filtfilt (which cannot be used because it requires float64)
	matData = filter(b, a, matData); % causal forward filter
	matData = flipud(matData); % reverse time
	matData = filter(b, a, matData); % causal forward filter again
	matData = flipud(matData); % reverse time back
