function [hMain,hAxAtlas,hAxAreas,hAxAreasPlot,hAxZeta,hAxClusters,hAxMua] = PH_GenGUI(sAtlas,sProbeCoords,sClusters)
	%[hMain,hAxAtlas,hAxAreas,hAxAreasPlot,hAxZeta,hAxClusters,hAxMua] = PH_GenGUI(sAtlas,sProbeCoords,sClusters)
	%
	% Many parts of this GUI are copied from, modified after, and/or
	% inspired by work by Andy Peters
	% (https://github.com/petersaj/AP_histology and
	% https://github.com/cortex-lab/allenCCF)
	%
	%Probe Histology Coordinate Adjuster GUI
	%Version 1.0 [2021-07-26]
	%	Created by Jorrit Montijn
	
	%% get atlas variables
	global boolIgnoreNeuroFinderRenderer;
	vecBregma = sAtlas.Bregma;% bregma in paxinos coordinates (x=ML,y=AP,z=DV)
	vecVoxelSize= sAtlas.VoxelSize;% voxel size
	matBrainMesh = sAtlas.BrainMesh;
	matColorMap=sAtlas.ColorMap;
	av = sAtlas.av; %paxinos coordinates: av(x,y,z) where (x=ML,y=AP,z=DV)
	st = sAtlas.st;
	tv = sAtlas.tv;
	
	%% get probe locdata
	%probe_vector_ccf =[...
	%   862   -20   732;...AP depth ML (wrt atlas at (0,0,0))
	%   815   359   690];
	sProbeCoords = PH_ExtractProbeCoords(sProbeCoords);
	dblProbeLengthMicrons = sProbeCoords.ProbeLengthMicrons;
	dblProbeLength = sProbeCoords.ProbeLength;
	sClusters.dblProbeLength = sProbeCoords.ProbeLengthMicrons;
	
	%probe tracker
	%neuro finder
	%probe locator
	%% Set up the gui
	%main figure
	hMain = figure('Menubar','none','color','w', ...
		'Name','NeuroFinder: Coordinate adjuster','Units','normalized','Position',[0.05,0.05,0.9,0.9],...
		'CloseRequestFcn',@PH_DeleteFcn);
	
	%test renderer
	if isempty(boolIgnoreNeuroFinderRenderer) || boolIgnoreNeuroFinderRenderer(1) == 0
		sRenderer = opengl('data');
		if ~strcmpi(hMain.Renderer,'OpenGL')
			%display message
			if ~strcmpi(sRenderer.HardwareSupportLevel,'full')
				warndlg(sprintf(...
					'The graphics renderer was not set to full hardware-accelerated OpenGL. \n\nI will change this now, but you might need to restart MATLAB. If you get any graphics errors, set the variable boolIgnoreNeuroFinderRenderer in the main function to true.'),...
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
	hAxAtlas = subplot(2,3,1);
	%vecGridColor = [0 0 0 0.3];
	vecGridColor = [0.7 0.7 0.7];
	hMesh = plot3(hAxAtlas, matBrainMesh(:,1), matBrainMesh(:,2), matBrainMesh(:,3), 'Color', vecGridColor);
	hold(hAxAtlas,'on');
	axis(hAxAtlas,'vis3d','equal','manual','off','ij');
	
	view([35,25]);
	%caxis([0 300]);
	[ml_max,ap_max,dv_max] = size(tv);
	xlim([-1,ml_max+1])
	ylim([-1,ap_max+1])
	zlim([-1,dv_max+1])
	h = rotate3d(hAxAtlas);
	h.Enable = 'on';
	h.ActionPostCallback = @PH_UpdateSlice;
	
	% Set up the probe area axes
	hAxAreas = subplot(2,3,3);
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
	hAxAreas2 = subplot(2,4,8);
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
	hAxZeta = subplot(2,3,2);
	set(hAxZeta,'XAxisLocation','top','YLim',[0,dblProbeLengthMicrons],'YColor','k','YDir','reverse');
	ylabel(hAxZeta,'Depth (\mum)');
	
	%% xcorr & clusters
	hAxClusters = subplot(2,4,6);
	ylabel(hAxClusters,'Depth (\mum)');
	set(hAxClusters,'XLim',[0,dblProbeLengthMicrons],'YLim',[0,dblProbeLengthMicrons],'YColor','k','YDir','reverse');
	
	hAxMua = subplot(2,4,7);
	hAxMuaIm=imagesc(hAxMua,magic(3));
	xlabel(hAxMua,'Depth (\mum)');
	axis(hAxMua,'equal');
	set(hAxMua,'YTickLabel','','XLim',[0,dblProbeLengthMicrons],'YLim',[0,dblProbeLengthMicrons],'YColor','k','YDir','reverse');
	
	%% Position the axes
	%set(axes_atlas,'Position',[-0.15,-0.1,1,1.2]);
	%set(axes_probe_areas,'Position',[0.7,0.45,0.03,0.5]);
	if strcmp(sAtlas.Type,'Allen-CCF-Mouse')
		set(hAxAtlas,'Position',[-0.15,-0.1,0.8,1.2]);
	elseif strcmp(sAtlas.Type,'Sprague-Dawley-Rat')
		set(hAxAtlas,'Position',[-0.1,0,0.7,1.2]);
	end
	set(hAxZeta,'Position',[0.6,0.5,0.3,0.4]);
	set(hAxAreas,'Position',[0.93,0.5,0.02,0.4]);
	set(hAxClusters,'Position',[0.6,0.065,0.1,0.4]);
	set(hAxMua,'Position',[0.668,0.065,0.3,0.4]);
	set(hAxAreas2,'Position',[0.93,0.065,0.02,0.4]);
	
	% Set up the text to display coordinates
	probe_coordinates_text = uicontrol('Style','text','String','', ...
		'Units','normalized','Position',[0,0.95,1,0.05], ...
		'BackgroundColor','w','HorizontalAlignment','left','FontSize',12);
	
	%% make buttons
	% freeze/unfreeze
	ptrButtonFreeze = uicontrol(hMain,'Style','togglebutton','FontSize',11,...
		'String',sprintf('Freeze'),...
		'Units','normalized',...
		'Position',[0.01 0.94 0.04 0.03],...
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
	
	% load zeta
	ptrButtonLoadEphys = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Load ephys'),...
		'Units','normalized',...
		'Position',[hAxZeta.Position(1)-0.03 0.94 0.06 0.03],...
		'Callback',@PH_LoadEphysFcn);
	
	%load ephys
	ptrButtonLoadZeta = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Load tuning'),...
		'Units','normalized',...
		'Position',[ptrButtonLoadEphys.Position(1)+ptrButtonLoadEphys.Position(3)+0.01 0.94 0.06 0.03],...
		'Callback',@PH_LoadZetaFcn);
	
	%help
	ptrButtonHelp = uicontrol(hMain,'Style','pushbutton','FontSize',11,...
		'String',sprintf('Help'),...
		'Units','normalized',...
		'Position',[0.93 0.95 0.03 0.03],...
		'Callback',@PH_DisplayControls);
	
	
	%% assign values to structure
	% Set the current axes to the atlas (dirty, but some gca requirements)
	axes(hAxAtlas);
	
	%build gui data
	sGUI=struct;
	sGUI.sProbeCoords = sProbeCoords;
	sGUI.sClusters = sClusters;
	sGUI.sAtlas = sAtlas;
	sGUI.cmap = colormap(hAxAreas); % Atlas colormap
	sGUI.bregma = vecBregma; % Bregma in atlas voxels for external referencing
	sGUI.probe_length = dblProbeLength; % Length of probe in atlas voxels
	sGUI.structure_plot_idx = []; % Plotted structures
	sGUI.step_size = 1;
	
	% user interface handles
	sGUI.handles.hMain = hMain;
	sGUI.handles.ptrButtonFreeze = ptrButtonFreeze;
	sGUI.handles.ptrButtonReset = ptrButtonReset;
	sGUI.handles.ptrButtonLoadProbe = ptrButtonLoadProbe;
	sGUI.handles.ptrButtonSave = ptrButtonSave;
	sGUI.handles.ptrButtonLoadEphys = ptrButtonLoadEphys;
	sGUI.handles.ptrButtonLoadZeta = ptrButtonLoadZeta;
	sGUI.handles.ptrButtonHelp = ptrButtonHelp;
	
	% plotting handles
	sGUI.handles.cortex_outline = hMesh;
	sGUI.handles.structure_patch = []; % Plotted structures
	sGUI.handles.axes_atlas = hAxAtlas; % Axes with 3D atlas
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
	sGUI.handles.probe_xcorr_bounds = gobjects;
	sGUI.handles.probe_clust = hAxClusters;
	sGUI.handles.probe_clust_bounds = gobjects;
	sGUI.handles.probe_zeta = hAxZeta;
	sGUI.handles.probe_zeta_bounds = gobjects;
	
	%other
	sGUI.probe_coordinates_text = probe_coordinates_text; % Probe coordinates text
	sGUI.lastPress = tic;
	sGUI.boolReadyForExit = false;
	sGUI.output = [];
	
	%set slice alpha (makes it slow)
	%alpha(sGUI.handles.slice_plot,0.65)
	
	% Set functions for key presses
	hManager = uigetmodemanager(hMain);
	[hManager.WindowListenerHandles.Enabled] = deal(false);
	set(hMain,'KeyPressFcn',@PH_KeyPress);
	
	% Upload gui_data
	guidata(hMain, sGUI);
	
	%% run initial functions
	%plot ephys
	PH_PlotProbeEphys(hAxZeta,hAxMua,hAxMuaIm,hAxClusters,sClusters);
	
	%set initial position
	PH_LoadProbeLocation(hMain,sProbeCoords,sAtlas);
	
	% Display controls
	PH_DisplayControls;
	