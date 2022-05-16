function PH_PlotProbeEphys(hMain,varargin)
	%% get data
	sGUI = guidata(hMain);
	sClusters = sGUI.sClusters;
	%get handles
	hAxMua = sGUI.handles.probe_xcorr;
	hAxMuaIm = sGUI.handles.probe_xcorr_im;
	hAxZeta = sGUI.handles.probe_zeta;
	hAxClust = sGUI.handles.probe_clust;
	hShowClust = sGUI.handles.ptrButtonShowClusters;
	if isempty(sClusters) || ~isfield(sClusters,'vecDepth') || isempty(sClusters.vecDepth)
		title(sGUI.handles.probe_zeta ,'No Ephys data loaded');
		%hide
		set(hAxZeta,'Visible','off');
		set(hAxClust,'Visible','off');
		set(hAxMua,'Visible','off');
		set(hAxMuaIm,'Visible','off');
		try
			set(sGUI.handles.probe_zeta_bounds,'Visible','off');
			set(sGUI.handles.probe_xcorr_bounds,'Visible','off');
			set(sGUI.handles.probe_clust_bounds,'Visible','off');
		catch
		end
		return
	else
		%show
		set(hAxZeta,'Visible','on');
		try
			set(sGUI.handles.probe_zeta_bounds,'Visible','on');
		catch
		end
	end
	
	%get data
	strShowClust = hShowClust.String{hShowClust.Value};
	strZetaTit = sClusters.strZetaTit;
	dblProbeLength = sClusters.dblProbeLength;
	indShowCells = true(size(sClusters.vecZeta));
	if isfield(sClusters,'ClustQual')
		cellUniqueClustQ = unique(sClusters.ClustQualLabel);
		%update list
		hShowClust.String = cat(1,'all',cellUniqueClustQ);
		
		%determine which cells to show
		if ~strcmpi(strShowClust,'all')
			indShowCells = strcmpi(sClusters.ClustQualLabel,strShowClust);
		end
	else
		sClusters.ClustQual = ones(size(indShowCells));
	end
	vecDepth = sClusters.vecDepth(indShowCells);
	vecZeta = sClusters.vecZeta(indShowCells);
	vecClustQual = sClusters.ClustQual(indShowCells);
	
	%% plot zeta
	vecUniqueQ = unique(sClusters.ClustQual);
	mapCol = redbluepurple(numel(vecUniqueQ));
	mapCol = mapCol(end:-1:1,:);
	mapCol(end,:) = [0 0 0]; %make good quality clusters black
	sGUI.handles.probe_zeta_points = scatter(hAxZeta,vecZeta,vecDepth,15,vecClustQual,'filled');
	hAxZeta.CLim = [min(vecUniqueQ) max(vecUniqueQ)];
	colormap(hAxZeta,mapCol);
	title(hAxZeta,strZetaTit);
	set(hAxZeta,'FontSize',12);
	ylabel(hAxZeta,'Depth (\mum)');
	set(hAxZeta,'XAxisLocation','top','YColor','k','YDir','reverse');
	set(hAxZeta,'YLim',[0,dblProbeLength]);
	setAllowAxesRotate(rotate3d(hAxZeta),hAxZeta,0);
	
	%update
	guidata(hMain,sGUI);
	
	%% calc mua & spike rates
	%get mua data
	if ~isfield(sClusters,'vecNormSpikeCounts')
		set(hAxClust,'Visible','off');
		set(hAxMua,'Visible','off');
		set(hAxMuaIm,'Visible','off');
		set(sGUI.handles.probe_xcorr_bounds,'Visible','off');
		set(sGUI.handles.probe_clust_bounds,'Visible','off');
		return;
	else
		set(hAxClust,'Visible','on');
		set(hAxMua,'Visible','on');
		set(hAxMuaIm,'Visible','on');
		try
			set(sGUI.handles.probe_xcorr_bounds,'Visible','on');
			set(sGUI.handles.probe_clust_bounds,'Visible','on');
		catch
		end
	end
	
	vecNormSpikeCounts = sClusters.vecNormSpikeCounts(indShowCells);
	vecContampP = sClusters.ContamP(indShowCells);
	cellSpikes = sClusters.cellSpikes(indShowCells);
	vecAllSpikeT = cell2vec(cellSpikes);
	
	%get channel mapping
	if isfield(sClusters,'ChanIdx') && isfield(sClusters,'ChanPos')
		vecChanIdx = sClusters.ChanIdx;
		matChanPos = sClusters.ChanPos;
	end
	
	% Get multiunit correlation
	n_corr_groups = 40;
	depth_group_edges = linspace(0,dblProbeLength,n_corr_groups+1);
	depth_group = discretize(vecDepth,depth_group_edges);
	depth_group_centers = depth_group_edges(1:end-1)+(diff(depth_group_edges)/2);
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
	
	mua_corr = corrcoef(binned_spikes_depth');
	mua_corr(diag(diag(true(size(mua_corr)))))=0;
	mua_corr(mua_corr<0)=0;
	mua_corr(isnan(mua_corr))=0;
	
	%% Plot spike depth vs rate
	sGUI.handles.probe_clust_points = scatter3(hAxClust,vecNormSpikeCounts,vecDepth,vecContampP,15,vecClustQual,'filled');
	hAxClust.CLim = [min(vecUniqueQ) max(vecUniqueQ)];
	colormap(hAxClust,mapCol);
	view(hAxClust,0,90);
	set(hAxClust,'YDir','reverse');
	ylim(hAxClust,[0,dblProbeLength]);
	xlabel(hAxClust,'Norm. log(N) spikes')
	title(hAxClust,'Spiking rate')
	set(hAxClust,'FontSize',12)
	ylabel(hAxClust,'Depth (\mum)');
	
	%% Plot multiunit correlation
	matMuaScaled = mua_corr./max(mua_corr(:));
	hAxMuaIm.XData = depth_group_centers;
	hAxMuaIm.YData = depth_group_centers;
	hAxMuaIm.CData = cat(3,ones(size(matMuaScaled)),1-matMuaScaled,1-matMuaScaled);
	title(hAxMua,'MUA correlation');
	set(hAxMua,'FontSize',12)
	setAllowAxesRotate(rotate3d(hAxMua),hAxMua,0);
	
	%update
	guidata(hMain,sGUI);
end
