function sSliceData = SH_ReadImages(sSliceData,vecMaxResolution)
	%SH_ReadImages Reads & reduces images if necessary
	%   sSliceData = SH_ReadImages(sSliceData,vecMaxResolution)
	
	if ~exist('vecMaxResolution','var') || isempty(vecMaxResolution)
		vecMaxResolution = [inf inf];
	end
	
	%msg
	ptrWaitbar = waitbar(0,['Loading and preparing images in ' sSliceData.path ', please wait...'],'Name','Loading images');
	ptrWaitbar.Children.Title.Interpreter = 'none';
	
	intImNum = numel(sSliceData.Slice);
	for intIm=1:intImNum
		%wait bar update
		try
			waitbar(intIm/intImNum,ptrWaitbar);
		catch
			sSliceData = [];
			return
		end
		
		%read
		if isempty(sSliceData.Slice(intIm).ImTransformed)
			imSlice = imread(fullpath(sSliceData.path,sSliceData.Slice(intIm).ImageName));
		else
			imSlice = sSliceData.Slice(intIm).ImTransformed;
		end
		
		%reduce
		if any(~isinf(vecMaxResolution))
			dblReduceBy = min(vecMaxResolution ./ size(imSlice,1:numel(vecMaxResolution)));
			imSlice = imresize(imSlice,dblReduceBy);
		end
		
		%save
		sSliceData.Slice(intIm).ImTransformed = imSlice;
		sSliceData.Slice(intIm).ImageSize = size(imSlice);
	end
	
	%run
	try	
		%close msg
		delete(ptrWaitbar);
	catch
	end
end

