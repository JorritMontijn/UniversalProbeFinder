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
	
	%make sure the file is not empty
	intImNum = numel(sLoad.sSliceData.Slice);
	if intImNum == 0
		errordlg(sprintf('File is empty: %s',strSliceFile),'Corrupt file');
		return;
	end
	boolValid = true;
end

