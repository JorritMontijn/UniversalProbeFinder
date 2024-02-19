function PH_PlotProbeEphys(hObject,eventdata)
	%% get data
	sGUI = guidata(hObject);
	hMain = sGUI.handles.hMain;
	sClusters = sGUI.sClusters;
	
	%check if source was list selector
	boolListSource = false;
	try
		boolListSource = strcmp(eventdata.Source.Style,'popupmenu');
	catch
		try %#ok<TRYNC>
			boolListSource = strcmp(eventdata.Style,'popupmenu');
		end
	end
	
	%get handles
	hAxMua = sGUI.handles.probe_xcorr;
	hAxMuaIm = sGUI.handles.probe_xcorr_im;
	hAxZeta = sGUI.handles.probe_zeta;
	hAxClust = sGUI.handles.probe_clust;
	ptrButtonLoadZeta = sGUI.handles.ptrButtonLoadZeta;
	ptrButtonLoadTsv = sGUI.handles.ptrButtonLoadTsv;
	ptrButtonPlotProp = sGUI.handles.ptrButtonPlotProp; %which property to plot?
	ptrButtonCategProp = sGUI.handles.ptrButtonCategProp; %which property to categorize?
	ptrButtonShowCateg = sGUI.handles.ptrButtonShowCateg; %which category of property to show?
	
	%hide while drawing
	cla(hAxZeta);
	cla(hAxClust);
	hAxMuaIm.CData = 255*ones(size(hAxMuaIm.CData));
	set(hAxZeta,'Visible','off');
	set(hAxClust,'Visible','off');
	set(ptrButtonLoadZeta,'Enable','off');
	set(ptrButtonLoadTsv,'Enable','off');
	set(ptrButtonPlotProp,'Enable','off');
	set(ptrButtonCategProp,'Enable','off');
	set(ptrButtonShowCateg,'Enable','off');
	set(hAxMua,'Visible','off');
	try,set(sGUI.handles.probe_zeta_bounds,'Visible','off');end
	try,set(sGUI.handles.probe_xcorr_bounds,'Visible','off');end
	try,set(sGUI.handles.probe_clust_bounds,'Visible','off');end
	drawnow;
	
	%cancel if no data
	if isempty(sClusters) || ~isfield(sClusters,'vecDepth') || isempty(sClusters.vecDepth)
		title(sGUI.handles.probe_zeta ,'No Ephys data loaded');
		return
	end
	
	%% fill lists
	if ~boolListSource
		%set default plotting property selection to zeta, or otherwise spike number
		ptrButtonPlotProp.String = PH_GetClusterPropertyList(hMain);
		intSelect = find(strcmpi(ptrButtonPlotProp.String,'Zeta')); %default
		if isempty(intSelect) || isnan(intSelect)
			intSelect = find(strcmpi(ptrButtonPlotProp.String,'NormSpikeCounts')); %2nd default
			if isempty(intSelect) || isnan(intSelect)
				intSelect = 1;
			end
		end
		ptrButtonPlotProp.Value=intSelect;
		
		%set default category selection to cluster quality
		ptrButtonCategProp.String = PH_GetClusterPropertyList(hMain);
		intSelect = find(strcmpi(ptrButtonCategProp.String,'ClustQualLabel')); %default
		if isempty(intSelect) || isnan(intSelect)
			intSelect = 1;
		end
		ptrButtonCategProp.Value=intSelect;
		ptrButtonShowCateg.String = PH_GetClusterCategories(hMain);
	end
	
	%% show cluster data
	strCategProp = ptrButtonCategProp.String{ptrButtonCategProp.Value};
	strShowCateg = ptrButtonShowCateg.String{ptrButtonShowCateg.Value};
	strLabelX = ptrButtonPlotProp.String{ptrButtonPlotProp.Value};
	dblProbeLength = sClusters.dblProbeLength;
	strCategField = PH_GetClusterField(sClusters,strCategProp);
	strXField = PH_GetClusterField(sClusters,strLabelX);
	vecDepth = sClusters.vecDepth;
	if isfield(sClusters,strCategField) && isfield(sClusters,strXField)
		vecPlotProperty = sClusters.(strXField);
		varColorProperty = sClusters.(strCategField);
	else
		vecPlotProperty = ones(size(vecDepth));
		varColorProperty = ones(size(vecDepth));
	end
	
	%find cells to plot
	if strcmp(strShowCateg,'all')
		indShowCells = true(size(vecDepth));
	elseif isnumeric(varColorProperty)
		indShowCells = varColorProperty==strShowCateg;
	else
		indShowCells = strcmpi(varColorProperty,strShowCateg);
	end
	if isempty(indShowCells)
		indShowCells = true(size(vecDepth));
	end
	vecColorProperty = val2idx(varColorProperty);

	%get plotting variables
	vecY = vecDepth(indShowCells);
	vecX = vecPlotProperty(indShowCells);
	vecC = vecColorProperty(indShowCells);
	
	%% plot zeta
	mapCol = redbluepurple(min(numel(unique(vecC)),255));
	sGUI.handles.probe_zeta_points = scatter(hAxZeta,vecX,vecY,15,vecC,'filled');
	if min(vecC) ~= max(vecC)
		hAxZeta.CLim = [min(vecC)-eps max(vecC)+eps];
	end
	colormap(hAxZeta,mapCol);
	title(hAxZeta,strLabelX,'Interpreter','none');
	set(hAxZeta,'FontSize',12);
	ylabel(hAxZeta,'Depth (\mum)');
	set(hAxZeta,'XAxisLocation','top','YColor','k','YDir','reverse');
	set(hAxZeta,'YLim',[0,dblProbeLength]);
	setAllowAxesRotate(rotate3d(hAxZeta),hAxZeta,0);
	
	%update
	guidata(hMain,sGUI);
	
	%% calc mua & spike rates
	%get channel mapping
	if isfield(sClusters,'ChanIdx') && isfield(sClusters,'ChanPos')
		vecChanIdx = sClusters.ChanIdx;
		matChanPos = sClusters.ChanPos;
	end
	
	
	%show ProbeMatrix if it exists
	if isfield(sClusters,'ProbeMatrix') && isfield(sClusters,'ProbeMatrixDepths') && isfield(sClusters,'ProbeMatrixTitle')
		error('to do');
	end
	
	%generate mua from spikes
	if isfield(sClusters,'cellSpikes')
		cellSpikes = sClusters.cellSpikes(indShowCells);
		vecAllSpikeT = cell2vec(cellSpikes);
		
		% Get multiunit correlation
		n_corr_groups = 40;
		depth_group_edges = linspace(0,dblProbeLength,n_corr_groups+1);
		depth_group = discretize(vecY,depth_group_edges);
		unique_depths = 1:length(depth_group_edges)-1;
		
		spike_binning = 0.01; % seconds
		corr_edges = nanmin(vecAllSpikeT):spike_binning:nanmax(vecAllSpikeT);
		corr_centers = corr_edges(1:end-1) + diff(corr_edges);
		
		binned_spikes_depth = zeros(length(unique_depths),length(corr_edges)-1);
		for curr_depth = 1:length(unique_depths)
			indUseClusters = depth_group == unique_depths(curr_depth);
			vecSpikeTimes = cell2vec(cellSpikes(indUseClusters));
			binned_spikes_depth(curr_depth,:) = histcounts(vecSpikeTimes, corr_edges);
		end
		
		ProbeMatrix = corrcoef(binned_spikes_depth');
		ProbeMatrix(diag(diag(true(size(ProbeMatrix)))))=0;
		ProbeMatrix(ProbeMatrix<0)=0;
		ProbeMatrix(isnan(ProbeMatrix))=0;
		ProbeMatrixDepths = depth_group_edges(1:end-1)+(diff(depth_group_edges)/2);
		ProbeMatrixTitle = 'MUA correlation';
	else
		ProbeMatrix = [];
		ProbeMatrixDepths = [];
		ProbeMatrixTitle = 'MUA correlation';
	end
	
	%% Plot spike depth vs rate
	sGUI.handles.probe_clust_points = scatter(hAxClust,vecC,vecY,15,vecC,'filled');
	if min(vecC) ~= max(vecC)
		hAxClust.CLim = [min(vecC)-eps max(vecC)+eps];
	end
	colormap(hAxClust,mapCol);
	%view(hAxClust,0,90);
	set(hAxClust,'YDir','reverse');
	ylim(hAxClust,[0,dblProbeLength]);
	xlabel(hAxClust,strCategProp,'Interpreter','none');
	set(hAxClust,'FontSize',12)
	ylabel(hAxClust,'Depth (\mum)');
	
	%% Plot multiunit correlation
	ProbeMatrix = ProbeMatrix./max(ProbeMatrix(:));
	hAxMuaIm.XData = ProbeMatrixDepths;
	hAxMuaIm.YData = ProbeMatrixDepths;
	hAxMuaIm.CData = cat(3,ones(size(ProbeMatrix)),1-ProbeMatrix,1-ProbeMatrix);
	title(hAxMua,ProbeMatrixTitle,'Interpreter','none');
	set(hAxMua,'FontSize',12)
	setAllowAxesRotate(rotate3d(hAxMua),hAxMua,0);
	
	%% enable gui
	set(hAxZeta,'Visible','on');
	set(hAxClust,'Visible','on');
	set(ptrButtonLoadZeta,'Enable','on');
	set(ptrButtonLoadTsv,'Enable','on');
	set(ptrButtonPlotProp,'Enable','on');
	set(ptrButtonCategProp,'Enable','on');
	set(ptrButtonShowCateg,'Enable','on');
	set(hAxMua,'Visible','on');
	try
		set(sGUI.handles.probe_zeta_bounds,'Visible','on');
		set(sGUI.handles.probe_xcorr_bounds,'Visible','on');
		set(sGUI.handles.probe_clust_bounds,'Visible','on');
	catch
	end
	
	%% update probe length
	%set new probe size
	dblRescaleFactor = dblProbeLength / sGUI.sProbeCoords.ProbeLengthMicrons;
	sGUI.sProbeCoords.ProbeLengthMicrons = sGUI.sProbeCoords.ProbeLengthMicrons * dblRescaleFactor;
	sGUI.sProbeCoords.ProbeLength = sGUI.sProbeCoords.ProbeLength * dblRescaleFactor;
	sGUI.sProbeCoords.ProbeLengthOriginal = sGUI.sProbeCoords.ProbeLengthOriginal * dblRescaleFactor;
	
	%update
	guidata(hMain,sGUI);
	
	%redraw
	matCartVec = PH_GetProbeVector(hMain);
	vecSphVec =  PH_CartVec2SphVec(matCartVec);
	vecLocationBrainIntersection = PH_GetBrainIntersection(matCartVec,sGUI.sAtlas.av);
	vecBregmaVec = PH_SphVec2BregmaVec(vecSphVec,vecLocationBrainIntersection,sGUI.sAtlas);
	vecBregmaVec(end) = dblProbeLength;
	vecSphVecNew = PH_BregmaVec2SphVec(vecBregmaVec,sGUI.sAtlas);
	PH_UpdateProbeCoordinates(hMain, vecSphVecNew, true);
end