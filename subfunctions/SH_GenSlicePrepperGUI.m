function SH_GenSlicePrepperGUI(sSliceData)
	%SH_GenSlicePrepperGUI GUI to adjust the slice orientation and mark histology trajectories
	%   SH_GenSlicePrepperGUI(sSliceData)
	
	%% load images
	%Obtains this pixel information
	vecScreenSize = get(0,'screensize');
	sSliceData = SH_ReadImages(sSliceData,vecScreenSize([4 3]));
	
	%% generate gui
	%main figure
	warning('off','MATLAB:hg:uicontrol:ValueMustBeWithinStringRange');
	warning('off','MATLAB:hg:uicontrol:StringMustBeNonEmpty');
	hMain = figure('WindowStyle','Normal','Menubar','none','color','w','NumberTitle','off',...
		'Name','UPF: Slice Prepper','Units','normalized','Position',[0.05,0.05,0.9,0.9],...
		'CloseRequestFcn',@SH_DeleteFcn);
	hMain.Visible = 'off';
	try
		warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
		warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
		jframe=get(hMain,'javaframe');
		jIcon=javax.swing.ImageIcon(fullpath(SH_getIniPath(),'icon.png'));
		jframe.setFigureIcon(jIcon);
	catch
	end
	
	%set up upper row of images
	[hHeader,sHeaderHandles] = SH_GenSliceHeader(hMain,sSliceData);
	
	%set info bar
	ptrTextInfo = uicontrol(hMain,'Style','text','FontSize',12,'string',sprintf('Image %d/%d: %s',1,0,''),'Units','normalized',...
		'Position',[0 0.77 1 0.03]);
	
	%make buttons
	ptrButtonHelp = uicontrol(hMain,'Style','pushbutton','FontSize',12,'string','Help','Units','normalized',...
		'Position',[0.9 0.73 0.08 0.04],'Callback',@SH_DisplaySlicePrepperControls);
	
	ptrButtonLoad = uicontrol(hMain,'Style','pushbutton','FontSize',12,'string','Load','Units','normalized',...
		'Position',[0.88 0.69 0.06 0.03],'Callback',@SH_LoadSliceData);
	
	ptrButtonSave = uicontrol(hMain,'Style','pushbutton','FontSize',12,'string','Save','Units','normalized',...
		'Position',[0.94 0.69 0.06 0.03],'Callback',@SH_SaveSlicePrepperFile);
	
	%set up image control buttons
	hImagePanel = uipanel(hMain,'FontSize',11,'Title','Image control','BackgroundColor','white','Position',[0.88 0.4 0.12 0.12]);
	
	ptrListChannels = uicontrol(hImagePanel,'Style','popupmenu','FontSize',11,'string',{'RGB','Red','Green','Blue'},'Value',1,'Units','normalized',...
		'Position',[0.1 0.5 0.8 0.25],'Callback',@SH_SelectChannel);
	
	ptrButtonFlipHorz = uicontrol(hImagePanel,'Style','pushbutton','FontSize',12,'string','Flip Image','Units','normalized',...
		'Position',[0.1 0.15 0.8 0.25],'Callback',@SH_FlipHorz);
	
	
	%set up track selector
	hTrackPanel = uipanel(hMain,'FontSize',11,'Title','Track selector','BackgroundColor','white','Position',[0.88 0.53 0.12 0.15]);
	
	ptrButtonNewTrack = uicontrol(hTrackPanel,'Style','pushbutton','FontSize',12,'string','New','Units','normalized',...
		'Position',[0.01 0.7 0.32 0.25],'Callback',@SH_NewTrack);
	
	ptrButtonEditTrack = uicontrol(hTrackPanel,'Style','pushbutton','FontSize',12,'string','Edit','Units','normalized',...
		'Position',[0.34 0.7 0.32 0.25],'Callback',@SH_EditTrack);
	
	ptrButtonRemTrack = uicontrol(hTrackPanel,'Style','pushbutton','FontSize',12,'string','Rem','Units','normalized',...
		'Position',[0.67 0.7 0.32 0.25],'Callback',@SH_RemTrack);
	
	ptrListSelectTrack = uicontrol(hTrackPanel,'Style','popupmenu','FontSize',11,'string',{sSliceData.Track(:).name},'Value',numel({sSliceData.Track(:).name}),'Units','normalized',...
		'Position',[0.01 0.45 0.98 0.25],'Callback',@SH_SelectTrack);
	
	ptrStaticTextActiveTrack = uicontrol(hTrackPanel,'Style','text','FontSize',11,'string','Selected:',...
		'BackgroundColor','white','Units','normalized',...
		'Position',[0.01 0.25 0.98 0.2]);
	vecColor = lines(1);
	ptrTextActiveTrack = uicontrol(hTrackPanel,'Style','text','FontSize',11,'string','',...
		'ForegroundColor',vecColor,'BackgroundColor','white','Units','normalized',...
		'Position',[0.01 0.05 0.98 0.2]);
	
	% Set up the slice axes
	hAxSlice = axes(hMain,'Position',[0 0 1 0.77]);
	hold(hAxSlice,'on');
	axis(hAxSlice,'off');
	
	%% assign values to structure
	%build gui data
	sGUI=struct;
	sGUI.intCurrIm = 1;
	sGUI.sSliceData = sSliceData;
	sGUI.LastClickLoc = [nan nan];
	sGUI.LastClickType = '';
	sGUI.LastUpdate = tic;
	sGUI.IsBusy = false;
	sGUI.name = 'SlicePrepper';
	
	% user interface handles
	sGUI.handles.hMain = hMain;
	sGUI.handles.hAxSlice = hAxSlice;
	sGUI.handles.hIm = [];
	sGUI.handles.hHeader = hHeader;
	sGUI.handles.vecHeaderAxes = sHeaderHandles.vecPlotAx;
	sGUI.handles.ptrTextInfo = ptrTextInfo;
	sGUI.handles.hDispHelp = [];
	
	%drawing handles
	sGUI.handles.hLastClick = [];
	sGUI.handles.hTempLine = [];
	
	%track selector handles
	sGUI.handles.hTrackPanel = hTrackPanel;
	sGUI.handles.ptrButtonNewTrack  = ptrButtonNewTrack;
	sGUI.handles.ptrButtonEditTrack = ptrButtonEditTrack;
	sGUI.handles.ptrButtonRemTrack = ptrButtonRemTrack;
	sGUI.handles.ptrListSelectTrack = ptrListSelectTrack;
	sGUI.handles.ptrStaticTextActiveTrack = ptrStaticTextActiveTrack;
	sGUI.handles.ptrTextActiveTrack = ptrTextActiveTrack;
	
	%image control handles
	sGUI.handles.hImagePanel = hImagePanel;
	sGUI.handles.ptrButtonFlipHorz = ptrButtonFlipHorz;
	sGUI.handles.ptrListChannels = ptrListChannels;
	
	%other buttons
	sGUI.handles.ptrButtonHelp = ptrButtonHelp;
	sGUI.handles.ptrButtonLoad = ptrButtonLoad;
	sGUI.handles.ptrButtonSave = ptrButtonSave;

	%other
	sGUI.lastPress = tic;
	sGUI.boolReadyForExit = false;
	sGUI.output = [];
	
	% Set functions for key presses
	hManager = uigetmodemanager(hMain);
	[hManager.WindowListenerHandles.Enabled] = deal(false);
	set(hMain,'KeyPressFcn',@SH_KeyPress);
	
	% Upload gui_data
	guidata(hMain, sGUI);
	
	%% run initial functions
	%make full screen
	maxfig(hMain);
	
	%plot images
	SH_PlotPrepIms(hMain);
	hMain.Visible = 'on';
	
	%show help
	SH_DisplaySlicePrepperControls(hMain);
end
