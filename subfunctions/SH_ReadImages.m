function sSliceData = SH_ReadImages(sSliceData,vecMaxResolution)
	%SH_ReadImages Reads & reduces images if necessary
	%   sSliceData = SH_ReadImages(sSliceData,vecMaxResolution)
	
	if ~exist('vecMaxResolution','var') || isempty(vecMaxResolution)
		vecMaxResolution = [inf inf];
	end
	
	%msg
	ptrWaitbar = waitbar(0,['Loading and preparing images in ' repmat('x',[1 numel(sSliceData.path)]) ', please wait...'],'Name','Loading images');
	ptrWaitbar.Children.Title.Interpreter = 'none';
	ptrWaitbar.Children.Title.String = ['Loading and preparing images in ' sSliceData.path ', please wait...'];
	
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
			
			%reduce
			if any(~isinf(vecMaxResolution))
				dblReduceBy = min(vecMaxResolution ./ xsize(imSlice,1:numel(vecMaxResolution)));
				imSlice = imresize(imSlice,dblReduceBy);
			end
			
			%fill range
			imSlice = double(imSlice)./double(intmax(class(imSlice)));
			if sSliceData.autoadjust
				for intCh=1:size(imSlice,3)
					imSlice(:,:,intCh) = imadjust(imSlice(:,:,intCh));
				end
			end
			
			%future feature: image adjustment in slice prepper
			%J = imadjust(I,[low_in high_in],[low_out high_out],gamma)
			
			%transform to uint16 [X by Y by 3]
			imSlice = uint16(imSlice*double(intmax('uint16')));
			if size(imSlice,3) == 1
				imSlice = repmat(imSlice,[1 1 3]);
			elseif size(imSlice,3) > 3
				imSlice = imSlice(:,:,1:3);
			end
		else
			imSlice = sSliceData.Slice(intIm).ImTransformed;
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

