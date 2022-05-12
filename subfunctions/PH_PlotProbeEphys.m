function PH_PlotProbeEphys(hMain,sClusters)
	%% get data
	sGUI = guidata(hMain);
	if isempty(sClusters) || ~isfield(sClusters,'vecDepth') || isempty(sClusters.vecDepth)
		title(sGUI.handles.probe_zeta ,'No Ephys data loaded');
		return
	end
	%get handles
	hAxMua = sGUI.handles.probe_xcorr;
	hAxMuaIm = sGUI.handles.probe_xcorr_im;
	hAxZeta = sGUI.handles.probe_zeta;
	hAxClust = sGUI.handles.probe_clust;
	
	%get data
	vecDepth = sClusters.vecDepth;
	vecZeta = sClusters.vecZeta;
	strZetaTit = sClusters.strZetaTit;
	if isfield(sClusters,'ClustQual')
		vecKilosortGood = sClusters.ClustQual;
	else
		vecKilosortGood = ones(size(vecZeta));
	end
		
	%% plot zeta
	sGUI.handles.probe_zeta_points = scatter3(hAxZeta,vecZeta,vecDepth,vecKilosortGood,15,'b','filled');
	view(hAxZeta,0,90);
	title(hAxZeta,strZetaTit);
	set(hAxZeta,'FontSize',12);
	ylabel(hAxZeta,'Depth (\mum)');
	set(hAxZeta,'XAxisLocation','top','YColor','k','YDir','reverse');
	%update
	guidata(hMain,sGUI);
	
	%% calc mua & spike rates
	%get mua data
	if ~isfield(sClusters,'vecNormSpikeCounts'),return;end
	vecNormSpikeCounts = sClusters.vecNormSpikeCounts;
	cellSpikes = sClusters.cellSpikes;
	dblProbeLength = sClusters.dblProbeLength;
	vecAllSpikeT = cell2vec(sClusters.cellSpikes);
	set(hAxZeta,'YLim',[0,dblProbeLength]);
	
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
	sGUI.handles.probe_clust_points = scatter3(hAxClust,vecNormSpikeCounts,vecDepth,vecKilosortGood,15,'k','filled');
	view(hAxClust,0,90);
	set(hAxClust,'YDir','reverse');
	ylim(hAxClust,[0,dblProbeLength]);
	xlabel(hAxClust,'N spikes')
	title(hAxClust,'Template depth & rate')
	set(hAxClust,'FontSize',12)
	ylabel(hAxClust,'Depth (\mum)');
	
	%% Plot multiunit correlation
	matMuaScaled = mua_corr./max(mua_corr(:));
	hAxMuaIm.XData = depth_group_centers;
	hAxMuaIm.YData = depth_group_centers;
	hAxMuaIm.CData = cat(3,ones(size(matMuaScaled)),1-matMuaScaled,1-matMuaScaled);
	title(hAxMua,'MUA correlation');
	set(hAxMua,'FontSize',12)
	
	%update
	guidata(hMain,sGUI);
end
