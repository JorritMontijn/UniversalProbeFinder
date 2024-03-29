function SF_GenSliceFinderGUI(sAtlas,sSliceData)
	%SF_GenSliceFinderGUI GUI to align the slice location to atlas coordinates
	%   SF_GenSliceFinderGUI(sAtlas,sSliceData)
	
	%% load images
	%Obtains this pixel information
	vecScreenSize = get(0,'screensize');
	sSliceData = SH_ReadImages(sSliceData,vecScreenSize([4 3]));
	
	%% get atlas variables
	boolIgnoreProbeFinderRenderer = PF_getIniVar('IgnoreRender');
	vecBregma = sAtlas.Bregma;% bregma in paxinos coordinates (x=ML,y=AP,z=DV)
	vecVoxelSize= sAtlas.VoxelSize;% voxel size
	matBrainMesh = sAtlas.BrainMesh;
	matColorMap=sAtlas.ColorMap;
	av = sAtlas.av; %paxinos coordinates: av(x,y,z) where (x=ML,y=AP,z=DV)
	st = sAtlas.st;
	tv = sAtlas.tv;
	
	%% generate gui
	%main figure
	warning('off','MATLAB:hg:uicontrol:ValueMustBeWithinStringRange');
	hMain = figure('WindowStyle','Normal','Menubar','none','color','w','NumberTitle','off',...
		'Name','UPF: Slice Finder','Units','normalized','Position',[0.05,0.05,0.9,0.9],...
		'CloseRequestFcn',@SF_DeleteFcn);
	hMain.Visible = 'off';
	try
		warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
		warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
		jframe=get(hMain,'javaframe');
		jIcon=javax.swing.ImageIcon(fullpath(SH_getIniPath(),'icon.png'));
		jframe.setFigureIcon(jIcon);
	catch
	end
	
	%% test renderer
	if isempty(boolIgnoreProbeFinderRenderer) || boolIgnoreProbeFinderRenderer(1) == 0
		sRenderer = opengl('data');
		if ~strcmpi(hMain.Renderer,'OpenGL')
			%display message
			if ~strcmpi(sRenderer.HardwareSupportLevel,'full')
				warndlg(sprintf(...
					'The graphics renderer was not set to full hardware-accelerated OpenGL. \n\nI will change this now, but you might need to restart MATLAB. If you get any graphics errors, set the variable IgnoreRender to 1 in the configPF.ini file.'),...
					'Graphics renderer');
			end
			
			% try changing settings
			try
				%OpenGL is way faster than painters for 3d stuff
				hMain.Renderer = 'OpenGL';
				opengl('save','hardware');
			catch
				errordlg('OpenGL acceleration failed: try updating your GPU drivers.','OpenGL error');
				opengl('save','software');
				hMain.Renderer = 'painters';
			end
		end
	else
		opengl('save','software');
		hMain.Renderer = 'painters';
	end
	
	
	%% set up GUI
	[hHeader,sHeaderHandles] = SH_GenSliceHeader(hMain,sSliceData);
	
	%set info bar
	ptrTextInfo = uicontrol(hMain,'Style','text','FontSize',12,'string',sprintf('Image %d/%d: %s',1,0,''),'Units','normalized',...
		'Position',[0 0.77 1 0.03]);
	
	%make buttons
	ptrButtonHelp = uicontrol(hMain,'Style','pushbutton','FontSize',12,'string','Help','Units','normalized',...
		'Position',[0.9 0.81 0.08 0.04],'Callback',@SF_DisplaySliceFinderControls);
	
	%ptrButtonExport = uicontrol(hMain,'Style','pushbutton','FontSize',12,'string','Export','Units','normalized',...
	%	'Position',[0.8 0.81 0.06 0.03],'Callback',@SF_ExportSliceFinderFile);
	
	ptrButtonLoad = uicontrol(hMain,'Style','pushbutton','FontSize',12,'string','Load','Units','normalized',...
		'Position',[0.62 0.81 0.06 0.03],'Callback',@SF_LoadSliceData);
	
	ptrButtonSave = uicontrol(hMain,'Style','pushbutton','FontSize',12,'string','Save','Units','normalized',...
		'Position',[0.685 0.81 0.06 0.03],'Callback',@SF_SaveSliceFinderFile);
	
	%set message area 1
	ptrTextMessages = uicontrol(hMain,'Style','text','FontSize',12,'string','','Units','normalized',...
		'Position',[0.02 0.81 0.2 0.03]);
	
	%set message area 2
	ptrTextClipboard = uicontrol(hMain,'Style','text','FontSize',12,'string','Curr copy: nan - Prev copy: nan','Units','normalized',...
		'Position',[0.23 0.81 0.17 0.03]);
	
	% Set up the atlas axes
	hAxAtlas = axes(hMain,'Position',[0 0 0.5 0.77]);
	vecGridColor = [0.7 0.7 0.7];
	hMesh = plot3(hAxAtlas, matBrainMesh(:,1), matBrainMesh(:,2), matBrainMesh(:,3), 'Color', vecGridColor);
	hold(hAxAtlas,'on');
	axis(hAxAtlas,'vis3d','equal','manual','off','ij');
	
	view([150,25]);
	[ml_max,ap_max,dv_max] = size(av);
	xlim([-1,ml_max+1])
	ylim([-1,ap_max+1])
	zlim([-1,dv_max+1])
	hRot = rotate3d(hAxAtlas);
	hRot.ButtonDownFilter = @SH_ButtonDownFilterFcn;
	hRot.Enable = 'on';
	hAxAtlas.Tag = 'Rotate3D';
	
	
	% Position the axes
	if strcmp(sAtlas.Type,'Allen-CCF-Mouse')
		set(hAxAtlas,'Position',[-0.05,-0.05,0.6,0.85]);
	elseif strcmp(sAtlas.Type,'Sprague-Dawley-Rat')
		set(hAxAtlas,'Position',[-0.05,-0.05,0.6,0.85]);
	elseif strcmp(sAtlas.Type,'CHARM-SARM-Macaque_NMT_v2_sym')
		set(hAxAtlas,'Position',[-0.05,-0.05,0.6,0.85]);
	else
		set(hAxAtlas,'Position',[-0.05,-0.05,0.6,0.85]);
	end
	
	% Set up the slice axes
	hAxSlice = axes(hMain,'Position',[0.5 0 0.5 0.77]);
	hold(hAxSlice,'on');
	axis(hAxSlice,'off','equal');
	%overlay axes
	hAxSliceOverlay = axes(hMain,'Position',[0.5 0 0.5 0.77],'Colormap',sAtlas.ColorMap);
	hold(hAxSliceOverlay,'on');
	axis(hAxSliceOverlay,'off','equal');
	
	%% assign values to structure
	%build gui data
	sGUI=struct;
	sGUI.intCurrIm = 1;
	sGUI.sSliceData = sSliceData;
	sGUI.sAtlas = sAtlas;
	sGUI.LastUpdate = tic;
	sGUI.IsBusy = false;
	sGUI.StepSize = 1;
	sGUI.AxesSign = 1; %1 or -1
	sGUI.OverlayType = 2;
	sGUI.CurrCopy = nan;
	sGUI.PrevCopy = nan;
	sGUI.sCopyBackup = struct;
	sGUI.CopyIms = [];
	sGUI.transparency = 0;
	sGUI.structure_plot_idx = [];
	sGUI.name = 'SliceFinder';
	
	% user interface handles
	sGUI.handles.hMain = hMain;
	sGUI.handles.hAxSlice = hAxSlice;
	sGUI.handles.hAxSliceOverlay = hAxSliceOverlay;
	sGUI.handles.hAxAtlas = hAxAtlas;
	sGUI.handles.hIm = [];%set(sGUI.handles.hIm);%,'AlphaData',0.5);
	sGUI.handles.hSliceInAtlas = surface(hAxAtlas,'EdgeColor','none');
	sGUI.handles.vecTrackHandlesInAtlas = [];
	sGUI.handles.hAtlasInSlice = surface(hAxSliceOverlay,'EdgeColor','none','FaceAlpha',0.5);
	sGUI.handles.hHeader = hHeader;
	sGUI.handles.vecHeaderAxes = sHeaderHandles.vecPlotAx;
	sGUI.handles.ptrTextInfo = ptrTextInfo;
	sGUI.handles.ptrTextMessages = ptrTextMessages;
	sGUI.handles.ptrTextClipboard = ptrTextClipboard;
	sGUI.handles.structure_patch = [];
	sGUI.handles.hDispHelp = [];
	
	%other buttons
	sGUI.handles.ptrButtonHelp = ptrButtonHelp;
	sGUI.handles.ptrButtonLoad = ptrButtonLoad;
	sGUI.handles.ptrButtonSave = ptrButtonSave;
	sGUI.handles.ptrButtonExport = [];%ptrButtonExport; %removed

	%other
	sGUI.boolAskSave = false;
	sGUI.boolReadyForExit = false;
	sGUI.output = [];
	
	% Set functions for key presses
	hManager = uigetmodemanager(hMain);
	[hManager.WindowListenerHandles.Enabled] = deal(false);
	set(hMain,'KeyPressFcn',@SF_KeyPress);
	
	% Upload gui_data
	guidata(hMain, sGUI);
	
	%% run initial functions
	%make full screen
	maxfig(hMain);
	
	%plot header+current slice and update slice in atlas + redraw atlas on slice
	SF_PlotIms(hMain);
	hMain.Visible = 'on';
	
	%show help
	SF_DisplaySliceFinderControls(hMain);
end
