function boolValid = SH_AssertSliceValidity(strSliceFile)
	%SH_AssertSliceValidity Ensure target file is valid
	%   boolValid = SH_AssertSliceValidity(strSliceFile)
	
	boolValid = false;
	%load
	if ~exist(strSliceFile,'file')
		return;
	end
	sLoad = load(strSliceFile);
	
	%make sure file is valid
	if ~isfield(sLoad,'sSliceData') || ~isfield(sLoad.sSliceData,'Slice') || isempty(sLoad.sSliceData.Slice)
		errordlg(sprintf('File is not a valid SliceFinder file: %s',strSliceFile),'Corrupt file');
		return;
	end
	
	%make sure all files are present
	intImNum = numel(sLoad.sSliceData.Slice);
	if intImNum == 0
		errordlg(sprintf('File is empty: %s',strSliceFile),'Corrupt file');
		return;
	end
	strLocalPath = fileparts(strSliceFile);
	indImPresent = false(1,intImNum);
	for intIm=1:intImNum
		strImFile = fullpath(strLocalPath,sLoad.sSliceData.Slice(intIm).ImageName);
		indImPresent(intIm) = exist(strImFile,'file') > 0;
	end
	boolValid = all(indImPresent);
	if ~boolValid
		errordlg(sprintf('%d image files missing, such as: %s',sum(indImPresent),sLoad.sSliceData.Slice(intIm).ImageName),'Corrupt file');
	end
end

