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
	
	%assign images
	intSliceNum = numel(sSliceData.Slice);
	for intSlice=1:intSliceNum
		%wait bar update
		try
			waitbar(intSlice/intSliceNum,ptrWaitbar);
		catch
			sSliceData = [];
			return
		end
		
		%read
		if isempty(sSliceData.Slice(intSlice).ImTransformed)
			%read which images to read and where to assign
			strIms = sSliceData.Slice(intSlice).ImageName;
			strAsg = sSliceData.Slice(intSlice).MergeMagic;
			cellIms = strsplit(strIms,';');
			cellAsg = strsplit(strAsg,';');
			indRem = cellfun(@isempty,cellIms) | cellfun(@isempty,cellAsg);
			cellIms(indRem)=[];
			cellAsg(indRem)=[];
			
			
			for intIm=1:numel(cellIms)
				imData = imread(fullpath(sSliceData.path,cellIms{intIm}));
				if intIm == 1
					imSlice=zeros(size(imData),'like',imData);
					if size(imSlice,3)==1,imSlice(:,:,3)=imSlice;end
					[intTilingX,intTilingY,dummyC,intTilingZ] = size(imSlice);
				end
				
				%assign X,Y,Z,C
				strImAsg=cellAsg{intIm};
				intX = str2double(getFlankedBy(strImAsg,'X','Y'));
				intY = str2double(getFlankedBy(strImAsg,'Y','Z'));
				intZ = str2double(getFlankedBy(strImAsg,'Z','C'));
				intC = str2double(getFlankedBy(strImAsg,'C','E'));
				
				vecAsgX = (1:intTilingX)+intX*intTilingX;
				vecAsgY = (1:intTilingY)+intY*intTilingY;
				vecAsgZ = (1:intTilingZ)+intZ*intTilingZ;
				if intC==0
					vecAsgC = 1:3;
					if size(imData,3) ~= 3
						imData = imData(:,:,1);
						imData = repmat(imData,[1 1 3]);
					end
				else
					vecAsgC = intC;
					if size(imData,3) > 1 && size(imData,3) >= intC
						imData = imData(:,:,intC);
					else
						imData = imData(:,:,1);
					end
				end
				imSlice(vecAsgX,vecAsgY,vecAsgC,vecAsgZ) = imData;
			end
			
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
			
			%transform to uint8 [X by Y by 3]
			imSlice = uint8(imSlice*double(intmax('uint8')));
			if size(imSlice,3) == 1
				imSlice = repmat(imSlice,[1 1 3]);
			elseif size(imSlice,3) > 3
				imSlice = imSlice(:,:,1:3);
			end
		else
			imSlice = sSliceData.Slice(intSlice).ImTransformed;
		end
		
		%save
		sSliceData.Slice(intSlice).ImTransformed = imSlice;
		sSliceData.Slice(intSlice).ImageSize = size(imSlice);
	end
	
	%run
	try
		%close msg
		delete(ptrWaitbar);
	catch
	end
end
