function hMain = PH_GenGUI(sAtlas,sProbeCoords,sClusters)
	%hMain = PH_GenGUI(sAtlas,sProbeCoords,sClusters)
	
	%% get atlas variables
	boolIgnoreProbeFinderRenderer = PF_getIniVar('IgnoreRender');
	vecBregma = sAtlas.Bregma;% bregma in paxinos coordinates (x=ML,y=AP,z=DV)
	vecVoxelSize= sAtlas.VoxelSize;% voxel size
	matBrainMesh = sAtlas.BrainMesh;
	matColorMap=sAtlas.ColorMap;
	av = sAtlas.av; %paxinos coordinates: av(x,y,z) where (x=ML,y=AP,z=DV)
	st = sAtlas.st;
	tv = sAtlas.tv;
	sProbeCoords.AtlasType = sAtlas.Type;
	sProbeCoords.VoxelSize = vecVoxelSize;
	sProbeCoords.Origin = vecBregma;
	
	%% get running type
	global sFigRP;
	if isfield(sFigRP,'ptrMainGUI') && ishandle(sFigRP.ptrMainGUI) && nargout > 0
		intRunType = 2;
	else
		intRunType = 1;
	end
	
	%% get probe locdata
	%probe_vector_ccf =[...
	%   862   -20   732;...AP depth ML (wrt atlas at (0,0,0))
	%   815   359   690];
	sProbeCoords = PH_ExtractProbeCoords(sProbeCoords);
	
	%update probe size using ephys metadata
	dblVoxelSize = mean(sProbeCoords.VoxelSize);
	if isfield(sClusters,'ProbeLength')
		sProbeCoords.ProbeLengthMicrons = sClusters.ProbeLength; %original length in microns
		sProbeCoords.ProbeLengthOriginal = sClusters.ProbeLength / dblVoxelSize; %original length in atlas voxels
		%sProbeCoords.ProbeLength = sClusters.ProbeLengthOriginal; %current length
	else
		%add default length
		if ~isfield(sProbeCoords,'ProbeLengthMicrons')
			sProbeCoords.ProbeLengthMicrons = 3840;
		end
		if ~isfield(sProbeCoords,'ProbeLengthOriginal')
			sProbeCoords.ProbeLengthOriginal = sProbeCoords.ProbeLength;
		end
	end
	
	%% set up the gui
	%main figure
	warning('off','MATLAB:unknownElementsNowStruc');
	hMain = figure('WindowStyle','Normal','Menubar','none','color','w','NumberTitle','off',...
		'Name','UPF: Probe Finder','Units','normalized','Position',[0.05,0.05,0.9,0.9],...
		'CloseRequestFcn',@PH_DeleteFcn);
	try
		warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
		warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
		jframe=get(hMain,'javaframe');
		jIcon=javax.swing.ImageIcon(fullpath(SH_getIniPath(),'icon.png'));
		jframe.setFigureIcon(jIcon);
	catch
	end
	
	%test renderer
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
	
	% Set up the atlas axes
	figure(hMain);
	hAxAtlas = subplot(4,4,1);
	vecGridColor = [0.7 0.7 0.7];
	hMesh = plot3(hAxAtlas, matBrainMesh(:,1), matBrainMesh(:,2), matBrainMesh(:,3), 'Color', vecGridColor);
	hold(hAxAtlas,'on');
	axis(hAxAtlas,'vis3d','equal','manual','off','ij');
	
	view([150,25]);
	[ml_max,ap_max,dv_max] = size(av);
	xlim([-1,ml_max+1])
	ylim([-1,ap_max+1])
	zlim([-1,dv_max+1])
	h = rotate3d(hAxAtlas);
	h.Enable = 'on';
	h.ActionPostCallback = @PH_UpdateSlice;
	
	% Set up the probe area axes
	dblProbeLengthMicrons = sProbeCoords.ProbeLengthMicrons;
	hAxAreas = axes(hMain,'Position',[0.93,0.5,0.02,0.4]);
	hAxAreas.ActivePositionProperty = 'position';
	set(hAxAreas,'FontSize',11);
	yyaxis(hAxAreas,'left');
	hAxAreasPlot = image(0);
	set(hAxAreas,'XTick','','YLim',[0,dblProbeLengthMicrons],'YTick','','YColor','k','YDir','reverse');
	colormap(hAxAreas,matColorMap);
	caxis([1,size(matColorMap,1)])
	yyaxis(hAxAreas,'right');
	set(hAxAreas,'XAxisLocation','top','XTick','','YLim',[0,dblProbeLengthMicrons],'YColor','k','YDir','reverse');
	
	% Set up the probe area axes
	hAxAreas2 = axes(hMain,'Position',[0.93,0.065,0.02,0.4]);
	hAxAreas2.ActivePositionProperty = 'position';
	set(hAxAreas2,'FontSize',11);
	yyaxis(hAxAreas2,'left');
	hAxAreasPlot2 = image(0);
	set(hAxAreas2,'XTick','','YLim',[0,dblProbeLengthMicrons],'YTick','','YColor','k','YDir','reverse');
	colormap(hAxAreas2,matColorMap);
	caxis([1,size(matColorMap,1)])
	yyaxis(hAxAreas2,'right');
	set(hAxAreas2,'XAxisLocation','top','XTick','','YLim',[0,dblProbeLengthMicrons],'YColor','k','YDir','reverse');
	
	%% ZETA
	hAxZeta = axes(hMain,'Position',[0.6,0.5,0.3,0.4]);
	h = rotate3d(hAxZeta);
	h.Enable = 'off';
	set(hAxZeta,'XAxisLocation','top','YLim',[0,dblProbeLengthMicrons],'YDir','reverse');
	ylabel(hAxZeta,'Depth (\mum)');
	hold(hAxZeta,'on');
	
	%% xcorr & clusters
	hAxClusters = subplot(2,4,6);
	ylabel(hAxClusters,'Depth (\mum)');
	set(hAxClusters,'XLim',[0,dblProbeLengthMicrons],'YLim',[0,dblProbeLengthMicrons],'YColor','k','YDir','reverse');
	
	hAxMua = subplot(2,4,7);
	hAxMuaIm=imagesc(hAxMua,[1 1 1]);
	xlabel(hAxMua,'Depth (\mum)');
	axis(hAxMua,'equal');
	set(hAxMua,'YTickLabel','','XLim',[0,dblProbeLengthMicrons],'YLim',[0,dblProbeLengthMicrons],'YColor','k','YDir','reverse');
	
	%% Position the axes
	if strcmp(sAtlas.Type,'Allen-CCF-Mouse')
		set(hAxAtlas,'Position',[-0.15,-0.1,0.8,1.2]);
	elseif strcmp(sAtlas.Type,'Sprague-Dawley-Rat')
		set(hAxAtlas,'Position',[-0.1,0,0.7,1.2]);
	elseif strcmp(sAtlas.Type,'CHARM-SARM-Macaque_NMT_v2_sym')
		set(hAxAtlas,'Position',[-0.15,-0.1,0.8,1.2]);
	else
		set(hAxAtlas,'Position',[-0.15,-0.1,0.8,1.2]);
	end
	set(hAxZeta,'Position',[0.6,0.5,0.3,0.4]);
	set(hAxAreas,'Position',[0.93,0.5,0.02,0.4]);
	set(hAxClusters,'Position',[0.6,0.065,0.1,0.4]);
	set(hAxMua,'Position',[0.668,0.065,0.3,0.4]);
	set(hAxAreas2,'Position',[0.93,0.065,0.02,0.4]);
	
	% Set up the text to display coordinates
	probe_coordinates_text = uicontrol('Style','text','String','', ...
		'Units','normalized','Position',[0.01,0.95,1,0.05], ...
		'BackgroundColor','w','HorizontalAlignment','left','FontSize',12);
	
	%% make buttons
	% rotate/data tip mode
	ptrButtonRotate = uicontrol(hMain,'Style','togglebutton','FontSize',11,...
		'String',sprintf('Rotate'),...
		'Value',0,...
		'Units','normalized',...
		'Position',[0.01 0.94 0.04 0.03],...
		'Callback',@PH_ToggleControl);
	
	% freeze/unfreeze
	ptrButtonFreeze = uicontrol(hMain,'Style','togglebutton','FontSize',11,...
		'String',sprintf('Freeze'),...
		'Value',0,...
		'Units','normalized',...
		'Position',[0.01 0.905 0.04 0.03],...
		'Callback',@PH_ToggleFreeze);
	
	%reset location
	ptrButtonReset = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Reset'),...
		'Units','normalized',...
		'Position',[0.06 0.94 0.04 0.03],...
		'Callback',@PH_ResetFcn);
	
	%load probe file
	ptrButtonLoadProbe = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Load probe file'),...
		'Units','normalized',...
		'Position',[0.11 0.94 0.065 0.03],...
		'Callback',@PH_LoadProbeFcn);
	
	%save probe file
	ptrButtonSave = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Save probe file'),...
		'Units','normalized',...
		'Position',[0.185 0.94 0.065 0.03],...
		'Callback',@PH_SaveProbeFile);
	
	%export with ephys file
	ptrButtonExportEphys = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Export ephys'),...
		'Units','normalized',...
		'Position',[0.255 0.94 0.065 0.03],...
		'Callback',@PH_ExportClusters);
	
	% load zeta
	ptrButtonLoadEphys = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Load ephys'),...
		'Units','normalized',...
		'Position',[hAxZeta.Position(1)-0.03 0.97 0.06 0.03],...
		'Callback',@PH_LoadEphysFcn);
	
	%load ephys
	ptrButtonLoadZeta = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Load tuning'),...
		'Units','normalized',...
		'Position',[ptrButtonLoadEphys.Position(1)+ptrButtonLoadEphys.Position(3)+0.01 0.97 0.06 0.03],...
		'Callback',@PH_LoadZetaFcn);
	
	%load tsv
	ptrButtonLoadTsv = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Load .tsv'),...
		'Units','normalized',...
		'Position',[ptrButtonLoadZeta.Position(1)+ptrButtonLoadZeta.Position(3)+0.01 0.97 0.06 0.03],...
		'Callback',@PH_LoadTsvFcn);
	
	%select property to plot (from tsv files)
	ptrButtonPlotProp = uicontrol(hMain,'Style','popupmenu','FontSize',11,...
		'String',{''},...
		'Units','normalized',...
		'Position',[ptrButtonLoadTsv.Position(1)+ptrButtonLoadTsv.Position(3)+0.01 0.97 0.06 0.03],...
		'Callback',@PH_SelectPlotProp);
	
	%select property to categorize (from tsv files)
	ptrButtonCategProp = uicontrol(hMain,'Style','popupmenu','FontSize',11,...
		'String',{''},...
		'Units','normalized',...
		'Position',[ptrButtonPlotProp.Position(1)+ptrButtonPlotProp.Position(3)+0.01 0.97 0.06 0.03],...
		'Callback',@PH_SelectCategProp);
	
	%show category
	ptrButtonShowCateg = uicontrol(hMain,'Style','popupmenu','FontSize',11,...
		'String',{''},...
		'Units','normalized',...
		'Position',[ptrButtonCategProp.Position(1) 0.97-ptrButtonCategProp.Position(4)-0.001 0.06 0.03],...
		'Callback',@PH_PlotProbeEphys);
	
	%discard other categories
	ptrButtonDiscardOtherCateg = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String','Discard others',...
		'Units','normalized',...
		'Position',[ptrButtonPlotProp.Position(1) ptrButtonShowCateg.Position(2) 0.06 0.03],...
		'Callback',@PH_DiscardOtherCategs);
	
	%reset discard
	ptrButtonUndoDiscard = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String','Undo',...
		'Units','normalized',...
		'Position',[ptrButtonShowCateg.Position(1)+ptrButtonShowCateg.Position(3)+0.01 ptrButtonShowCateg.Position(2) 0.04 0.03],...
		'Callback',@PH_UndoDiscardCategs);
	
	
	%set show mask to all true
	try
		for i=1:numel(sClusters.Clust)
			sClusters.Clust(i).ShowMaskPF = true;
		end
	catch
	end
	
	%help
	ptrButtonHelp = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Help'),...
		'Units','normalized',...
		'Position',[0.97 0.97 0.03 0.03],...
		'Callback',@PH_DisplayControls);
	
	%try adding tooltips
	try
		ptrButtonRotate.Tooltip = 'Switch between (1) rotating the brain and (2) showing data tip popups';
		ptrButtonFreeze.Tooltip = 'Toggle slice updating in brain view when rotating';
		ptrButtonReset.Tooltip = 'Reset probe position to track points';
		ptrButtonLoadProbe.Tooltip = 'Load SliceFinder or probe coordinate file';
		ptrButtonSave.Tooltip = 'Save probe coordinate file';
		ptrButtonExportEphys.Tooltip = 'Export UPF file including probe coordinates and all electrophysiology data';
		ptrButtonLoadEphys.Tooltip = 'Load SpikeGLX, Kilosort, Acquipix, or UPF file';
		ptrButtonLoadZeta.Tooltip = 'Load tuning property file, or stimulus onset file to compute stimulus responsiveness';
		ptrButtonLoadTsv.Tooltip = 'Load .tsv file(s) with cluster properties';
		ptrButtonPlotProp.Tooltip = 'Select variable to plot in top graph';
		ptrButtonCategProp.Tooltip = 'Select variable to plot in bottom graph and use for category selection';
		ptrButtonShowCateg.Tooltip = 'Select category to plot';
		ptrButtonDiscardOtherCateg.Tooltip = 'Discard clusters not in selected category';
		ptrButtonHelp.Tooltip = 'Display commands and re-enable all buttons';
	end
	
	%disable buttons
	set(ptrButtonLoadZeta,'Enable','off');
	set(ptrButtonLoadTsv,'Enable','off');
	set(ptrButtonPlotProp,'Enable','off');
	set(ptrButtonCategProp,'Enable','off');
	set(ptrButtonShowCateg,'Enable','off');
	set(ptrButtonExportEphys,'Enable','off');
	set(ptrButtonDiscardOtherCateg,'Enable','off');
	set(ptrButtonUndoDiscard,'Enable','off');
	
	%% assign values to structure
	% Set the current axes to the atlas (dirty, but some gca requirements)
	axes(hAxAtlas);
	
	%build gui data
	sGUI=struct;
	sGUI.sProbeCoords = sProbeCoords;
	sGUI.sClusters = sClusters;
	sGUI.sAtlas = sAtlas;
	sGUI.cmap = colormap(hAxAreas); % Atlas colormap
	%sGUI.bregma = vecBregma; % Bregma in atlas voxels for external referencing
	%sGUI.probe_length = dblProbeLength; % Length of probe in atlas voxels
	sGUI.structure_plot_idx = []; % Plotted structures
	sGUI.step_size = 1;
	sGUI.transparency = 0;
	sGUI.runtype = intRunType;
	sGUI.name = 'ProbeFinder';
	
	% user interface handles
	sGUI.handles.hMain = hMain;
	sGUI.handles.ptrButtonRotate = ptrButtonRotate;
	sGUI.handles.ptrButtonFreeze = ptrButtonFreeze;
	sGUI.handles.ptrButtonReset = ptrButtonReset;
	sGUI.handles.ptrButtonLoadProbe = ptrButtonLoadProbe;
	sGUI.handles.ptrButtonSave = ptrButtonSave;
	sGUI.handles.ptrButtonExportEphys = ptrButtonExportEphys;
	sGUI.handles.ptrButtonLoadEphys = ptrButtonLoadEphys;
	sGUI.handles.ptrButtonLoadZeta = ptrButtonLoadZeta;
	sGUI.handles.ptrButtonLoadTsv = ptrButtonLoadTsv;
	sGUI.handles.ptrButtonPlotProp = ptrButtonPlotProp;
	sGUI.handles.ptrButtonCategProp = ptrButtonCategProp;
	sGUI.handles.ptrButtonShowCateg = ptrButtonShowCateg;
	sGUI.handles.ptrButtonDiscardOtherCateg = ptrButtonDiscardOtherCateg;
	sGUI.handles.ptrButtonUndoDiscard = ptrButtonUndoDiscard;
	sGUI.handles.ptrButtonHelp = ptrButtonHelp;
	sGUI.handles.hDispHelp = [];
	
	% plotting handles
	sGUI.handles.cortex_outline = hMesh;
	sGUI.handles.structure_patch = []; % Plotted structures
	sGUI.handles.axes_atlas = hAxAtlas; % Axes with 3D atlas
	sGUI.handles.hAxAtlas = hAxAtlas; % Axes with 3D atlas
	sGUI.handles.axes_probe_areas = hAxAreas; % Axes with probe areas
	sGUI.handles.axes_probe_areas2 = hAxAreas2; % Axes with probe areas
	sGUI.handles.slice_plot = surface('EdgeColor','none'); % Slice on 3D atlas
	sGUI.handles.slice_volume = 'av'; % The volume shown in the slice
	sGUI.handles.bregma = scatter3(sGUI.handles.axes_atlas,vecBregma(1),vecBregma(2),vecBregma(3),100,'g.','linewidth',1); %bregma
	
	%probe-related handles
	sGUI.handles.probe_points = scatter3(sGUI.handles.axes_atlas,-100,-100,-100,100,'g.','linewidth',2); % will contain histology points
	sGUI.handles.probe_vector_cart = line([-100 -200],[-100 -200],[-100 -200],'Color','b','linewidth',1.5); % will contain atlas voxel-based location
	sGUI.handles.probe_tip = scatter3(sGUI.handles.axes_atlas,-100,-100,-100,100,'b.','linewidth',2); % will contain probe tip location
	sGUI.handles.probe_intersect = scatter3(sGUI.handles.axes_atlas,-100,-100,-100,100,'rx','linewidth',2); %will contain brain intersection
	sGUI.handles.probe_areas_plot = hAxAreasPlot; % Color-coded probe regions
	sGUI.handles.probe_areas_plot2 = hAxAreasPlot2; % Color-coded probe regions
	sGUI.handles.probe_xcorr = hAxMua;
	sGUI.handles.probe_xcorr_im = hAxMuaIm;
	sGUI.handles.probe_xcorr_bounds = line([-100 -200],[-100 -200],'Color','b','linewidth',1.5); % will contain atlas voxel-based location
	sGUI.handles.probe_clust = hAxClusters;
	sGUI.handles.probe_clust_points = gobjects;
	sGUI.handles.probe_clust_bounds = line([-100 -200],[-100 -200],'Color','b','linewidth',1.5); % will contain atlas voxel-based location
	sGUI.handles.probe_zeta = hAxZeta;
	sGUI.handles.probe_zeta_bounds = line([-100 -200],[-100 -200],'Color','b','linewidth',1.5); % will contain atlas voxel-based location
	sGUI.handles.probe_zeta_points = gobjects;
	
	%other
	sGUI.probe_coordinates_text = probe_coordinates_text; % Probe coordinates text
	sGUI.lastPress = tic;
	sGUI.boolReadyForExit = false;
	sGUI.output = [];
	
	%enable rotation
	h = rotate3d(hAxAtlas);
	h.Enable = 'on';
	
	% Set functions for key presses
	hManager = uigetmodemanager(hMain);
	[hManager.WindowListenerHandles.Enabled] = deal(false);
	set(hMain,'KeyPressFcn',@PH_KeyPress);
	
	% Upload gui_data
	guidata(hMain, sGUI);
	
	%% run initial functions
	%make full screen
	maxfig(hMain);
	
	%set initial position
	PH_LoadProbeLocation(hMain,sProbeCoords,sAtlas);
	
	%plot ephys
	PH_PlotProbeEphys(hMain);
	
	% Display controls
	PH_DisplayControls(hMain,false);
	