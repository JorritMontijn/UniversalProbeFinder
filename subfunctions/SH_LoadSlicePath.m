function sSliceData = SH_LoadSlicePath(strDefaultPath)
	%SH_LoadSlicePath Load images in slice path
	%   sSliceData = SH_LoadSlicePath(strDefaultPath)
	
	%SliceData structure:
	%sSliceData = struct;
	%sSliceData.autoadjust = true/false; %automatically adjust images with imadjust
	%sSliceData.path = 'C:/images';
	%sSliceData.editdate = '20220524';
	%%image pre-process + track id data
	%sSliceData.Slice(i).ImageName = 'im1;im2'; %source files
	%sSliceData.Slice(i).MergeMagic = 'F00S00X00Y00Z00C00E;F00S01X00Y00Z00C00E'; => assignment data
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
			strDefaultPath=cd();
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

		% assert bioformats
		intOutFlag = assertBioFormats();
		boolUseCzi = intOutFlag == 0;
		if boolUseCzi
			%unpack czi images and remove from list
			
			%find czi images
			sDir = dir(fullpath(strSlicePath,'*.czi'));
			cellCziFiles = {sDir.name};
			
			%unpack czi images and remove from list
			indUnpackCzis = true(size(cellCziFiles));
			for intCziIdx=1:numel(cellCziFiles)
				strFullFileName = cellCziFiles{intCziIdx};
				[strFilePath,strFileName,strFileExt]=fileparts(strFullFileName);
				
				%check if already unpacked
				cellUnpackedImages = findImFiles(strSlicePath);
				if any(cellfun(@(x,y) strcmp(x(1:min(numel(x),numel(y))),y(1:min(numel(x),numel(y)))),...
						cellUnpackedImages,cellfill(strFileName,size(cellUnpackedImages))))
					%already unpacked; ignore
					indUnpackCzis(intCziIdx) = false;
				end
			end
			
			%unpack
			vecUnpackFiles = find(indUnpackCzis);
			boolExport = false;
			if numel(vecUnpackFiles) > 0
				prompt = '\fontsize{10}Czi image export resolution (pixels):';
				dlgtitle = 'Enter size';
				opts=struct;
				opts.Interpreter='tex';
				strAns = inputdlg(prompt,dlgtitle,1,{'1000'},opts);
				dblReqResolution = str2double(strAns);
				if isempty(dblReqResolution) || isnan(dblReqResolution)
					boolExport = false;
				else
					boolExport = true;
					hWaitbar = waitbar(0,'','Name','Unpacking czis','WindowStyle','modal');
					hWaitbar.Children.Title.Interpreter = 'none';
				end
			end
			if boolExport
				for intFileIdx=1:numel(vecUnpackFiles)
					intCziIdx = vecUnpackFiles(intFileIdx);
					strFullFileName = cellCziFiles{intCziIdx};
					[strFilePath,strFileName,strFileExt]=fileparts(strFullFileName);
					if ishandle(hWaitbar)
						waitbar(intFileIdx/numel(vecUnpackFiles),hWaitbar,sprintf('Unpacking %d/%d: %s',intFileIdx,numel(vecUnpackFiles),strFullFileName));
					end
					SH_UnpackCZI(strSlicePath,strFileName,dblReqResolution);
				end
				%close waitbar
				if ishandle(hWaitbar)
					close(hWaitbar);
				end
			end
		end
		
		%find images
		cellPotentialImages = findImFiles(strSlicePath);
		
		%confirm with user
		[cellLoadImages,cellMergeMagic,boolAutoAdjust] = userConfirmImages(cellPotentialImages,strSlicePath);
		if isempty(cellLoadImages)
			sSliceData = [];
			return
		end
		
		%parse assignment & expand structure
		[intImNum,vecTargetImage] = getImageNum(cellMergeMagic);
		
		%add to structure
		for intSlice=intImNum:-1:1
			%add all source images
			sSliceData.Slice(intSlice).ImageName = '';
			sSliceData.Slice(intSlice).MergeMagic = '';
			vecAddIms = find(vecTargetImage==intSlice);
			for intImIdx=1:numel(vecAddIms)
				intIm=vecAddIms(intImIdx);
				sSliceData.Slice(intSlice).ImageName = [sSliceData.Slice(intSlice).ImageName ';' cellLoadImages{intIm}];
				sSliceData.Slice(intSlice).MergeMagic = [sSliceData.Slice(intSlice).MergeMagic ';' cellMergeMagic{intIm}];
			end
		end
		sSliceData.autoadjust = boolAutoAdjust;
	end
end
function [intImNum,vecTargetImage] = getImageNum(cellMergeMagic)
	%ignore C, count rest
	[cellUnique,ia,vecTargetImage]=unique(cellfun(@getFlankedBy,cellMergeMagic,cellfill('',size(cellMergeMagic)),cellfill('C',size(cellMergeMagic)),'UniformOutput',false));
	intImNum = numel(cellUnique);
end
function cellPotentialImages = findImFiles(strSlicePath)
	
	%compile valid formats
	sImFormats = imformats();
	
	%crop exts
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
end
function Slice = genDummySlice()
%Slice structure
	Slice = struct;
	Slice(1).ImageName = '';%'im1;im2'
	Slice(1).MergeMagic = ''; %'F00S00X00Y00Z00C00E;F00S01X00Y00Z00C00E'
	Slice(1).ImageSize = []; %[x y] => to make sure we're not using a different file later
	Slice(1).ImTransformed = []; %[X by Y by C]; => midline-corrected image
	Slice(1).MidlineX = 0.5; %location of midline; 0.5
	Slice(1).Center = [0,0,0]; %location of center of image in [ML,AP,DV] atlas space
	Slice(1).RotateAroundML = 0; %degrees up/down rotation in atlas space (relative to coronal)
	Slice(1).RotateAroundDV = 0; %degrees left/right rotation in atlas space (relative to coronal)
	Slice(1).RotateAroundAP = 0; %degrees counterclockwise rotation in atlas space (same as VecMidline) (relative to coronal)
	Slice(1).ResizeUpDown = 1; %stretch/shrink atlas relative to slice in up/down (presumably ~DV) axis
	Slice(1).ResizeLeftRight = 1; %stretch/shrink  atlas relative to slice in left/right (presumably ~ML) axis
	Slice(1).TrackClick(1).Vec = [nan nan; nan nan]; %[x1 y1; x2 y2] => normalized location in [0 1] range
	Slice(1).TrackClick(1).Track = 0; %track #k
	Slice(1).TrackClick(1).hLine = []; %handle to line
	Slice(1).TrackClick(1).hScatter = []; %handle to Scatter
	Slice(:) = []; %remove data
end
function Track = genDummyTrack()
	%Track structure
	Track = struct;
	Track(1).name = 'track1'; %name of track 
	Track(1).marker = '*'; %marker of track 
	Track(1).color = lines(1); %color of track
	Track(:) = [];
end
function cellMergeMagic = encodeMagic(intFieldSize,vecF,vecS,vecX,vecY,vecZ,vecC)
	intIms = numel(vecF);
	if ~exist('vecS','var') || isempty(vecS),vecS=zeros(1,intIms);end
	if ~exist('vecX','var') || isempty(vecX),vecX=zeros(1,intIms);end
	if ~exist('vecY','var') || isempty(vecY),vecY=zeros(1,intIms);end
	if ~exist('vecZ','var') || isempty(vecZ),vecZ=zeros(1,intIms);end
	if ~exist('vecC','var') || isempty(vecC),vecC=zeros(1,intIms);end
	
	strFieldSize = ['%0' num2str(intFieldSize) 'd'];
	strFormat = ['F' strFieldSize 'S' strFieldSize 'X' strFieldSize 'Y' strFieldSize 'Z' strFieldSize 'C' strFieldSize 'E'];
	cellMergeMagic = cellfill(strFormat,size(vecF));
	for intIm=1:intIms
		cellMergeMagic{intIm} = sprintf(cellMergeMagic{intIm},vecF(intIm),vecS(intIm),vecX(intIm),vecY(intIm),vecZ(intIm),vecC(intIm));
	end
end
function matImLocs = decodeMagic(cellMergeMagic,cellPotentialImages)
	matImLocs = nan(numel(cellPotentialImages),6);
	for intIm=1:numel(cellPotentialImages)
		strMergeMagic = cellMergeMagic{intIm};
		matImLocs(intIm,1) = str2double(getFlankedBy(strMergeMagic,'F','S'));
		matImLocs(intIm,2) = str2double(getFlankedBy(strMergeMagic,'S','X'));
		matImLocs(intIm,3) = str2double(getFlankedBy(strMergeMagic,'X','Y'));
		matImLocs(intIm,4) = str2double(getFlankedBy(strMergeMagic,'Y','Z'));
		matImLocs(intIm,5) = str2double(getFlankedBy(strMergeMagic,'Z','C'));
		matImLocs(intIm,6) = str2double(getFlankedBy(strMergeMagic,'C','E'));
	end
end
function cellDispList = formatDispList(cellMergeMagic,cellPotentialImages,intFieldSize)
	%inverse of retrieveMagic
	
	%find which variables are homogenous
	strSeparator = '  <  ';
	matImLocs = decodeMagic(cellMergeMagic,cellPotentialImages);
	vecNonEmpty = find(range(matImLocs,1)~=0);
	strFieldSize = ['%0' num2str(intFieldSize) 'd'];
	strFieldKeys = 'FSXYZC';
	
	%fill list
	intIms = numel(cellMergeMagic);
	cellDispList = cell(intIms,1);
	for intIm=1:intIms
		strAssignString = '';
		for intAssignField=1:numel(vecNonEmpty)
			intField = vecNonEmpty(intAssignField);
			strAssignString = strcat(strAssignString,sprintf([strFieldKeys(intField) strFieldSize],matImLocs(intIm,intField)));
		end
		cellDispList{intIm} = [strAssignString strSeparator cellPotentialImages{intIm}];
	end
	
	%sort
	cellDispList = sort(cellDispList);
end
function [cellMergeMagic,cellLoadImages,intFieldSize] = retrieveMagic(cellDispList)
	%inverse of formatDispList
	
	%check field size and which fields are present
	strSeparator = '  <  ';
	strFieldKeys = '(F|S|X|Y|Z|C)';
	strMagic1 = getFlankedBy(cellDispList{1},'',strSeparator);
	cellFields = regexp(strMagic1,['[' strFieldKeys(2:2:end) ']\d*'],'match');
	intFieldSize = length(cellFields{1})-1;
	vecFields = regexp(strMagic1,strFieldKeys);
	vecFieldsPresent = ismember(strFieldKeys(2:2:end),strMagic1(vecFields));
	
	%retrieve field values and image name
	intIms = numel(cellDispList);
	cellLoadImages = cell(intIms,1);
	vecF = zeros(intIms,1);
	vecS = zeros(intIms,1);
	vecX = zeros(intIms,1);
	vecY = zeros(intIms,1);
	vecZ = zeros(intIms,1);
	vecC = zeros(intIms,1);
	for intIm=1:intIms
		%name
		cellLoadImages{intIm} = getFlankedBy(cellDispList{intIm},strSeparator,'');
		
		%fields
		cellFields = regexp(getFlankedBy(cellDispList{intIm},'',strSeparator),['[' strFieldKeys(2:2:end) ']\d*'],'match');
		for intField=1:numel(cellFields)
			strKey = cellFields{intField}(1);
			if strcmp(strKey,'F')
				vecF(intIm) = str2double(cellFields{intField}(2:end));
			elseif strcmp(strKey,'S')
				vecS(intIm) = str2double(cellFields{intField}(2:end));
			elseif strcmp(strKey,'X')
				vecX(intIm) = str2double(cellFields{intField}(2:end));
			elseif strcmp(strKey,'Y')
				vecY(intIm) = str2double(cellFields{intField}(2:end));
			elseif strcmp(strKey,'Z')
				vecZ(intIm) = str2double(cellFields{intField}(2:end));
			elseif strcmp(strKey,'C')
				vecC(intIm) = str2double(cellFields{intField}(2:end));
			end
		end
	end
	
	%assign file if images are not unique
	cellMergeMagic = encodeMagic(intFieldSize,vecF,vecS,vecX,vecY,vecZ,vecC);
end
function [cellLoadImages,cellMergeMagic,boolAutoAdjust] = userConfirmImages(cellPotentialImages,strSlicePath)
	%create GUI: OK, delete, move up, move down
	hImConfGui = figure('Name','Confirm Images','WindowStyle','Normal','Menubar','none','NumberTitle','off','Position',[500 300 400 600]);
	hImConfGui.Units = 'normalized';
	
	%generate list with default assignments
	intIms = numel(cellPotentialImages);
	intFieldSize = ceil(log10(intIms+1));
	cellMergeMagic = encodeMagic(intFieldSize,1:intIms);
	cellDispList = formatDispList(cellMergeMagic,cellPotentialImages,intFieldSize);
	
	%create buttons
	handles = struct;
	handles.hMain = hImConfGui;
	handles.hDispHelp = [];
	handles.ptrButtonAccept = uicontrol(hImConfGui,'Style','pushbutton','String','Accept',...
		'Units','normalized','FontSize',12,'Position',[0.05 0.945 0.3 0.05],...
		'Callback',@UCI_Accept);
	
	handles.ptrButtonMergeMagic = uicontrol(hImConfGui,'Style','pushbutton','String','Auto Assign',...
		'Units','normalized','FontSize',10,'Position',[0.4 0.945 0.29 0.05],...
		'Callback',@UCI_MergeMagic);
	
	handles.ptrButtonAutoAdjust = uicontrol(hImConfGui,'Style','checkbox','String','Auto-adjust',...
		'Units','normalized','FontSize',10,'Position',[0.7 0.95 0.25 0.04],'backgroundcolor',[1 1 1]);
	
	handles.ptrText = uitext(hImConfGui,'Style','text','String','Image:',...
		'VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',[0.05 0.902 0.1 0.04]);
	
	handles.ptrButtonMergeEdit = uicontrol(hImConfGui,'Style','pushbutton','String','Edit',...
		'Units','normalized','FontSize',10,'Position',[0.15 0.9 0.25 0.04],...
		'Callback',@UCI_Edit);
	
	handles.ptrButtonDelete = uicontrol(hImConfGui,'Style','pushbutton','String','Discard',...
		'Units','normalized','FontSize',10,'Position',[0.40 0.9 0.25 0.04],...
		'Callback',@UCI_Delete);
	
	handles.ptrButtonHelp = uicontrol(hImConfGui,'Style','pushbutton','String','Help',...
		'Units','normalized','FontSize',10,'Position',[0.80 0.9 0.15 0.04],...
		'Callback',@UCI_Help);
	
	%create list
	handles.ptrImList = uicontrol(hImConfGui,'Style','listbox','String',cellDispList,...
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
		[cellMergeMagic,cellLoadImages,intFieldSize] = retrieveMagic(handles.ptrImList.String);
		close(hImConfGui);
	else
		boolAutoAdjust = [];
		cellMergeMagic = [];
		cellLoadImages = [];
	end
end
function UCI_Edit(hMain,eventdata)
	%get data
	handles = guidata(hMain);
	cellDispList = handles.ptrImList.String;
	intIm = handles.ptrImList.Value;
	
	%retrieve current image assignments
	[cellMergeMagic,cellLoadImages,intFieldSize] = retrieveMagic(cellDispList);
	strAssignment = cellMergeMagic{intIm};
	strTitle = cellLoadImages{intIm};
	
	%generate edit gui
	strNewAssignment = SH_EditAssignment(strTitle,strAssignment);
	
	%edit assignment
	if ~strcmp(strAssignment,strNewAssignment)
		cellMergeMagic{intIm} = strNewAssignment;
		
		%reorder
		handles.ptrImList.String = formatDispList(cellMergeMagic,cellLoadImages,intFieldSize);
	end
end
function UCI_MergeMagic(hMain,eventdata)
	%get data
	handles = guidata(hMain);
	cellDispList = handles.ptrImList.String;
	intIm = handles.ptrImList.Value;
	
	%retrieve current image assignments
	[cellMergeMagic,cellLoadImages,intFieldSize] = retrieveMagic(cellDispList);
	
	%generate edit gui
	sRegExpAssignment = SH_MagicAssignment();
	
	%set new image assignments
	cellMergeMagic = UCI_AssignRegexp(cellLoadImages,sRegExpAssignment,intFieldSize);
	
	%reorder
	handles.ptrImList.String = formatDispList(cellMergeMagic,cellLoadImages,intFieldSize);
end
function cellMergeMagic = UCI_AssignRegexp(cellLoadImages,sRegExpAssignment,intFieldSize)
	
	intIms = numel(cellLoadImages);
	vecF = zeros(intIms,1);
	vecS = zeros(intIms,1);
	vecX = zeros(intIms,1);
	vecY = zeros(intIms,1);
	vecZ = zeros(intIms,1);
	vecC = zeros(intIms,1);
	cellF = cell(intIms,1);
	for intIm=1:intIms
		%name
		strIm = cellLoadImages{intIm};
		
		%file
		cellF(intIm) = regexp(strIm,sRegExpAssignment.File,'match');
		
		%image
		cellTok = regexp(strIm,sRegExpAssignment.Image,'match');
		if ~isempty(cellTok),vecS(intIm) = str2double(cellTok{1}(2:end));end
		
		%ch1
		cellTokC1 = regexp(strIm,sRegExpAssignment.Ch1,'match');
		if ~isempty(cellTokC1),vecC(intIm) = 1;end
		
		%ch2
		cellTokC2 = regexp(strIm,sRegExpAssignment.Ch2,'match');
		if ~isempty(cellTokC2),vecC(intIm) = 2;end
		
		%ch3
		cellTokC3 = regexp(strIm,sRegExpAssignment.Ch3,'match');
		if ~isempty(cellTokC3),vecC(intIm) = 3;end
		
		%assign 0 if no channel is detected
		if isempty(cellTokC1) && isempty(cellTokC2) && isempty(cellTokC3)
			vecC(intIm) = 0;
		end
		
		%x
		cellTok = regexp(strIm,sRegExpAssignment.X,'match');
		if ~isempty(cellTok),vecC(intIm) = str2double(cellTok{1}(2:end));end
		
		%y
		cellTok = regexp(strIm,sRegExpAssignment.Y,'match');
		if ~isempty(cellTok),vecY(intIm) = str2double(cellTok{1}(2:end));end
		
		%z
		cellTok = regexp(strIm,sRegExpAssignment.Z,'match');
		if ~isempty(cellTok),vecZ(intIm) = str2double(cellTok{1}(2:end));end
	end
	
	%check if F is required
	%merge without F
	intIms = numel(vecS);
	strFieldSize = ['%0' num2str(intFieldSize) 'd'];
	strFormat = ['S' strFieldSize 'X' strFieldSize 'Y' strFieldSize 'Z' strFieldSize 'C' strFieldSize 'E'];
	cellMergeMagic = cellfill(strFormat,size(vecS));
	for intIm=1:intIms
		cellMergeMagic{intIm} = sprintf(cellMergeMagic{intIm},vecS(intIm),vecX(intIm),vecY(intIm),vecZ(intIm),vecC(intIm));
	end
	
	%check if unique
	cellUnique = unique(cellMergeMagic);
	if numel(cellUnique) < numel(cellMergeMagic)
		%if not unique, add F
		[cellUniqueFiles,dummy,vecF] = unique(cellF);
	else
		%ignore F
		vecF = zeros(size(vecF));
	end
	
	%encode
	cellMergeMagic = encodeMagic(intFieldSize,vecF,vecS,vecX,vecY,vecZ,vecC);
end
function UCI_Accept(hMain,eventdata)
	%get data
	handles = guidata(hMain);
	handles.hMain.UserData = 'Accept';
	uiresume(handles.hMain);
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
function UCI_Help(hObject,eventdata)
	%get data
	
	%check if help is already open
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.hMain);
	if ~isempty(sGUI.hDispHelp) && ishandle(sGUI.hDispHelp)
		figure(sGUI.hDispHelp);return;
	end
	
	% Print controls
	CreateStruct.Interpreter = 'tex';
	CreateStruct.WindowStyle = 'non-modal';
	cellTxt = {'\fontsize{11}'...
		'You can use the list to select which to images load (and combine)' ...
		'' ...
		'\bfAssignment format: \rm' ...
		'Each image can be combined with others to create a single slice, including x/y tiling and channel recombinations. All images are sorted by the hierarchy:'...
		'   File > Image scene > X offset > Y offset > Z offset > Channel'...
		'Displayed as:'...
		'   F > S > X > Y > Z > C'...
		''...
		'All image files that share the same File (F) and Image scene (S) will be combined into a single slice.'...
		''...
		'To the right of these codes, you can see a separator " < " followed by the source image file name.'...
		''...
		'\bfAuto assign: \rm' ...
		'This button will show a pop-up box where you can define the regular expressions that are used to extract slice information from the image file names. If you exported your slices from a .czi file, the default parameters should work automatically.' ...
		''...
		'\bfEdit: \rm' ...
		'This button will show a pop-up box where you can manually edit the slice assignment of your image. Note that the program will not check if you have overlapping assignments. It will assign images from top to bottom, possibly overwriting previous data.' ...
		''...
		'\bfAuto-adjust: \rm' ...
		'If ticked, images will receive automatic histogram adjustments when loaded.' ...
		''...
		'\bfDiscard: \rm' ...
		'Remove the selected image from the list.' ...
		};
	
	hMsgBox = msgbox( ...
		cellTxt, ...
		'Controls',CreateStruct);
	
	%add handles & return to hMsgBox
	hRealMain = sGUI.hMain;
	sMiniGUI = sGUI;
	sMiniGUI.hMain = hRealMain;
	guidata(hMsgBox,sMiniGUI);

	%add link to manual
	vecPos = [0 (1 - 1/numel(cellTxt)) 1 1/numel(cellTxt)];
	hAx = axes(hMsgBox,'Position',vecPos);
	axis(hAx,'off');
	hTxt = text(hAx,0.9,0.5,'$\mathrm{\underline{Manual}}$',...
		'color',[0 0 .8],'FontSize',12,'Interpreter','latex',...
		'HorizontalAlignment','right');
	hTxt.ButtonDownFcn = @(~,~)web('https://github.com/JorritMontijn/UniversalProbeFinder/blob/main/UserGuide_UniversalProbeFinder.pdf'); % this opens the website
	
	%reset focus
	set(sGUI.ptrButtonHelp, 'enable', 'off');
	drawnow;
	set(sGUI.ptrButtonHelp, 'enable', 'on');
		
	%release
	sGUI.handles.hDispHelp = hMsgBox;
	guidata(sGUI.hMain,sGUI);
end