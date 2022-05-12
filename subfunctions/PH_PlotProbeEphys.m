function PH_PlotProbeEphys(hAxZeta,hAxMua,hAxMuaIm,hAxClust,sClusters)
	%% get data
	if isempty(sClusters) || ~isfield(sClusters,'vecDepth') || isempty(sClusters.vecDepth)
		title(hAxZeta,'No Ephys data loaded');
		return
	end
	vecUseClusters = sClusters.vecUseClusters;
	vecNormSpikeCounts = sClusters.vecNormSpikeCounts;
	vecDepth = sClusters.vecDepth;
	vecZeta = sClusters.vecZeta;
	strZetaTit = sClusters.strZetaTit;
	cellSpikes = sClusters.cellSpikes;
	dblProbeLength = sClusters.dblProbeLength;
	vecAllSpikeT = cell2vec(sClusters.cellSpikes);
	
	%% plot zeta
	scatter(hAxZeta,vecZeta,vecDepth,15,'b','filled');
	title(hAxZeta,strZetaTit);
	set(hAxZeta,'FontSize',12);
	ylabel(hAxZeta,'Depth (\mum)');
	set(hAxZeta,'XAxisLocation','top','YLim',[0,dblProbeLength],'YColor','k','YDir','reverse');
	
	%% calc mua & spike rates
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
	scatter(hAxClust,vecNormSpikeCounts,vecDepth,15,'k','filled');
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
	
end
