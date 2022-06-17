function sSliceData = SH_LoadSlicePath(strDefaultPath)
	%SH_LoadSlicePath Load images in slice path
	%   sSliceData = SH_LoadSlicePath(strDefaultPath)
	
	%SliceData structure:
	%sSliceData = struct;
	%sSliceData.autoadjust = true/false; %automatically adjust images with imadjust
	%sSliceData.path = 'C:/images';
	%sSliceData.editdate = '20220524';
	%%image pre-process + track id data
	%sSliceData.Slice(i).ImageName = 'im1';
	%sSliceData.Slice(i).ImageSize = [nan nan]; %[x y] => original size
	%sSliceData.Slice(i).ImTransformed = [X by Y by C]; => midline-corrected image
	%sSliceData.Slice(i).MidlineX = X; => x-location of midline in corrected image
	%sSliceData.Slice(i).TrackClick(j).Vec = [nan nan; nan nan]; %[x1 y1; x2 y2] => normalized location in [0 1] range
	%sSliceData.Slice(i).TrackClick(j).Track = 1; %track #k
	%sSliceData.Track(k).name = 'track1'; %name of track #k
	%sSliceData.Track(k).marker = '*'; %marker of track #k
	%sSliceData.Track(k).color = lines(1); %color of track #k
	%%image alignment to atlas data
	%sSliceData.Slice(i).Center = [0,0,0]; %location of center of image in [ML,AP,DV] atlas space
	%sSliceData.Slice(i).RotateAroundML = 1; %pitch: degrees up/down rotation in atlas space (relative to coronal)
	%sSliceData.Slice(i).RotateAroundDV = 2; %yaw: degrees left/right rotation in atlas space (relative to coronal)
	%sSliceData.Slice(i).RotateAroundAP = 3; %roll: degrees counterclockwise rotation in atlas space (same as VecMidline) (relative to coronal)
	%sSliceData.Slice(i).ResizeUpDown = 1; %stretch/shrink atlas relative to slice in up/down (presumably ~DV) axis
	%sSliceData.Slice(i).ResizeLeftRight = 1; %stretch/shrink  atlas relative to slice in left/right (presumably ~ML) axis
	
	%% default path
	sSliceData = [];
	if ~exist('strDefaultPath','var') || isempty(strDefaultPath)
		try
			sRP = RP_populateStructure();
			strDefaultPath = sRP.strProbeLocPath;
		catch
			strDefaultPath=fileparts(mfilename('fullpath'));
		end
	end
	
	%ask what to load
	strSlicePath = uigetdir(strDefaultPath,'Select folder with slice images');
	if isempty(strSlicePath) || strSlicePath(1) == 0,return;end
	
	%% find slice file, otherwise create
	%load
	strFormat = '*_UniversalProbeFinder*.mat';
	sDir = dir(fullpath(strSlicePath,strFormat));
	%load options
	cellFiles = {sDir.name};
	cellFiles(end+1) = {'New'};
	if numel(cellFiles) > 1
		%ask which one
		[intFile,boolContinue] = listdlg('ListSize',[300 100],'Name','Load SliceFinder file','PromptString','Select file to load:',...
			'SelectionMode','single','ListString',cellFiles);
		if ~boolContinue,return;end
	else
		intFile = 1;
	end
	if intFile < numel(cellFiles)
		strSliceFile = fullpath(strSlicePath,sDir(intFile).name);
		
		%make sure all images are present
		boolValid = SH_AssertSliceValidity(strSliceFile);
		if ~boolValid,return;end
		
		%load
		sLoad = load(strSliceFile);
		sSliceData = sLoad.sSliceData;
	else
		% create slice data file
		sSliceData = struct;
		sSliceData.path = strSlicePath;
		sSliceData.editdate = getDate();
		sSliceData.Slice = genDummySlice();
		sSliceData.Track = genDummyTrack();

		%compile valid formats
		sImFormats = imformats();
		cellExt = {};
		for intFormat=1:numel(sImFormats)
			varExt=sImFormats(intFormat).ext;
			if numel(varExt) > 1
				cellExt((end+1):(end+2)) = varExt;
			else
				cellExt(end+1) = varExt;
			end
		end
		
		%find all image files
		cellPotentialImages = {};
		for intExt=1:numel(cellExt)
			sDir = dir(fullpath(strSlicePath,['*.' cellExt{intExt}]));
			cellPotentialImages((end+1):(end+numel({sDir.name}))) = {sDir.name};
		end
		
		%confirm with user
		[cellLoadImages,boolAutoAdjust] = userConfirmImages(cellPotentialImages);
		if isempty(cellLoadImages)
			sSliceData = [];
			return
		end
		
		%add to structure
		for intSlice=numel(cellLoadImages):-1:1
			sSliceData.Slice(intSlice).ImageName = cellLoadImages{intSlice};
		end
		sSliceData.autoadjust = boolAutoAdjust;
	end
end
function Slice = genDummySlice()
%Slice structure
	Slice = struct;
	Slice(1).ImageName = 'im1';
	Slice(1).ImageSize = [nan nan]; %[x y] => to make sure we're not using a different file later
	Slice(1).ImTransformed = zeros(5,4,3); %[X by Y by C]; => midline-corrected image
	Slice(1).MidlineX = 0.5;
	Slice(1).Center = [0,0,0]; %location of center of image in [ML,AP,DV] atlas space
	Slice(1).RotateAroundML = 1; %degrees up/down rotation in atlas space (relative to coronal)
	Slice(1).RotateAroundDV = 2; %degrees left/right rotation in atlas space (relative to coronal)
	Slice(1).RotateAroundAP = 3; %degrees counterclockwise rotation in atlas space (same as VecMidline) (relative to coronal)
	Slice(1).ResizeUpDown = 1; %stretch/shrink atlas relative to slice in up/down (presumably ~DV) axis
	Slice(1).ResizeLeftRight = 1; %stretch/shrink  atlas relative to slice in left/right (presumably ~ML) axis
	Slice(1).TrackClick(1).Vec = [nan nan; nan nan]; %[x1 y1; x2 y2] => normalized location in [0 1] range
	Slice(1).TrackClick(1).Track = 1; %track #k
	Slice(1).TrackClick(1).hLine = []; %handle to line
	Slice(1).TrackClick(1).hScatter = []; %handle to Scatter
	Slice(:) = [];
	
end
function Track = genDummyTrack()
	%Track structure
	Track = struct;
	Track(1).name = 'track1'; %name of track 
	Track(1).marker = '*'; %marker of track 
	Track(1).color = lines(1); %color of track
	Track(:) = [];
end
function [cellLoadImages,boolAutoAdjust] = userConfirmImages(cellPotentialImages)
	%create GUI: OK, delete, move up, move down
	hImConfGui = figure('Name','Confirm Images','WindowStyle','Normal','Menubar','none','NumberTitle','off','Position',[500 300 300 600]);
	hImConfGui.Units = 'normalized';
	
	%create buttons
	handles = struct;
	handles.hMain = hImConfGui;
	handles.ptrButtonAccept = uicontrol(hImConfGui,'Style','pushbutton','String','Accept',...
		'Units','normalized','FontSize',12,'Position',[0.1 0.945 0.3 0.05],...
		'Callback',@UCI_Accept);
	
	handles.ptrButtonAutoAdjust = uicontrol(hImConfGui,'Style','checkbox','String','Auto-adjust',...
		'Units','normalized','FontSize',10,'Position',[0.6 0.95 0.3 0.04],'backgroundcolor',[1 1 1]);
	
	handles.ptrButtonDelete = uicontrol(hImConfGui,'Style','pushbutton','String','Delete',...
		'Units','normalized','FontSize',10,'Position',[0.01 0.9 0.32 0.04],...
		'Callback',@UCI_Delete);
	
	handles.ptrButtonMoveUp = uicontrol(hImConfGui,'Style','pushbutton','String','Move Up',...
		'Units','normalized','FontSize',10,'Position',[0.34 0.9 0.32 0.04],...
		'Callback',@UCI_MoveUp);
	
	handles.ptrButtonMoveDown = uicontrol(hImConfGui,'Style','pushbutton','String','Move Down',...
		'Units','normalized','FontSize',10,'Position',[0.67 0.9 0.32 0.04],...
		'Callback',@UCI_MoveDown);
	
	%create list
	handles.ptrImList = uicontrol(hImConfGui,'Style','listbox','String',cellPotentialImages,...
		'Units','normalized','FontSize',9,'Position',[0.01 0.01 0.98 0.88]);
	
	%set guidata
	guidata(hImConfGui,handles);
		
	%move
	movegui(hImConfGui,'center');
	
	%wait until accept is pressed
	uiwait(hImConfGui);
	
	if ishandle(hImConfGui) && strcmp(hImConfGui.UserData,'Accept')
		boolAutoAdjust = handles.ptrButtonAutoAdjust.Value;
		handles = guidata(hImConfGui);
		cellLoadImages = handles.ptrImList.String;
		close(hImConfGui);
	else
		boolAutoAdjust = [];
		cellLoadImages = [];
	end
end
function UCI_Accept(hMain,eventdata)
	%get data
	handles = guidata(hMain);
	handles.hMain.UserData = 'Accept';
	uiresume(handles.hMain);
end
function UCI_MoveUp(hMain,eventdata)
	%get data
	handles = guidata(hMain);
	cellImList = handles.ptrImList.String;
	intIm = handles.ptrImList.Value;
	
	%check if not already top
	if isempty(cellImList) || isempty(intIm) || intIm == 1,return;end
	
	%swap
	cellImList([intIm intIm-1]) = cellImList([intIm-1 intIm]);
	handles.ptrImList.Value = intIm - 1;
	
	%update list
	handles.ptrImList.String = cellImList;
end
function UCI_MoveDown(hMain,eventdata)
	%get data
	handles = guidata(hMain);
	cellImList = handles.ptrImList.String;
	intIm = handles.ptrImList.Value;
	
	%check if not already bottom
	if isempty(cellImList) || isempty(intIm) || intIm == numel(cellImList),return;end
	
	%swap
	cellImList([intIm intIm+1]) = cellImList([intIm+1 intIm]);
	handles.ptrImList.Value = intIm + 1;
	
	%update list
	handles.ptrImList.String = cellImList;
end
function UCI_Delete(hMain,eventdata)
	%get data
	handles = guidata(hMain);
	cellImList = handles.ptrImList.String;
	intIm = handles.ptrImList.Value;
	
	%check if emptyt
	if isempty(cellImList) || isempty(intIm),return;end
	
	%swap
	cellImList(intIm) = [];
	
	%update list
	handles.ptrImList.String = cellImList;
	if handles.ptrImList.Value > numel(cellImList)
		handles.ptrImList.Value = numel(cellImList);
	end
end