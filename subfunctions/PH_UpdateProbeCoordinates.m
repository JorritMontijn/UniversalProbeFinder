function PH_UpdateProbeCoordinates(hMain,vecSphereVector)
	% Get guidata
	sGUI = guidata(hMain);
	
	%calculate vectors in different spaces
	probe_vector_sph = vecSphereVector;
	probe_vector_cart = PH_SphVec2CartVec(vecSphereVector);
	vecLocationBrainIntersection = PH_GetBrainIntersection(probe_vector_cart,sGUI.sAtlas.av);
	probe_vector_bregma = PH_SphVec2BregmaVec(vecSphereVector,vecLocationBrainIntersection,sGUI.sAtlas);
	%fprintf('PH_UpdateProbeCoordinates:\n');
	%fprintf(' Sphere: %s\n',sprintf('%d ',round(probe_vector_sph)));
	%fprintf(' Cart: %s\n',sprintf('%d ',round(probe_vector_cart)));
	%fprintf(' Brain: %s\n',sprintf('%d ',round(vecLocationBrainIntersection)));
	%fprintf(' Bregma: %s\n',sprintf('%d ',round(probe_vector_bregma)));
	
	% (if the probe doesn't intersect the brain, don't update)
	if isempty(vecLocationBrainIntersection)
		return
	end
	
	%add new vectors to current position
	sGUI.sProbeCoords.sProbeAdjusted.probe_vector_cart = probe_vector_cart;
	sGUI.sProbeCoords.sProbeAdjusted.probe_vector_sph = probe_vector_sph;
	sGUI.sProbeCoords.sProbeAdjusted.probe_vector_intersect = vecLocationBrainIntersection;
	sGUI.sProbeCoords.sProbeAdjusted.probe_vector_bregma = probe_vector_bregma;
	
	%get locations along probe
	[probe_area_ids,probe_area_boundaries,probe_area_centers] = PH_GetProbeAreas(probe_vector_cart,sGUI.sAtlas.av);
	probe_area_idx = probe_area_ids(round(probe_area_centers));
	probe_area_labels = sGUI.sAtlas.st.acronym(probe_area_idx);
	probe_area_full = sGUI.sAtlas.st.name(probe_area_idx);
	
	%add locations to GUI data
	sGUI.sProbeCoords.sProbeAdjusted.probe_area_ids = probe_vector_cart;
	sGUI.sProbeCoords.sProbeAdjusted.probe_area_labels = probe_area_labels;
	sGUI.sProbeCoords.sProbeAdjusted.probe_area_full = probe_area_full;
	
	% update gui
	set(sGUI.handles.probe_vector_cart,'XData',probe_vector_cart(:,1), ...
		'YData',probe_vector_cart(:,2),'ZData',probe_vector_cart(:,3));
	set(sGUI.handles.probe_intersect,'XData',vecLocationBrainIntersection(1), ...
		'YData',vecLocationBrainIntersection(2),'ZData',vecLocationBrainIntersection(3));
	set(sGUI.handles.probe_tip,'XData',probe_vector_cart(1,1), ...
		'YData',probe_vector_cart(1,2),'ZData',probe_vector_cart(1,3));
	guidata(hMain, sGUI);
	
	
	% Update the text
	probe_text = ['Brain intersection at: ' ....
		num2str(roundi(probe_vector_bregma(1),1)) ' ML, ', ...
		num2str(roundi(probe_vector_bregma(2),1)) ' AP; ', ...
		'Probe depth ' num2str(roundi(probe_vector_bregma(5),1)) ', ' ...
		num2str(roundi(probe_vector_bregma(3),1)) char(176) ' ML angle, ' ...
		num2str(roundi(probe_vector_bregma(4),1)) char(176) ' AP angle, ' ...
		'Probe length ' num2str(round(probe_vector_bregma(6))) ' microns, ' ...
		num2str(round(sGUI.step_size*100)) '% step size' ...
		];
	set(sGUI.probe_coordinates_text,'String',probe_text);
	
	% Update the probe areas
	dblVoxelSize = mean(sGUI.sAtlas.VoxelSize);
	yyaxis(sGUI.handles.axes_probe_areas,'right');
	set(sGUI.handles.probe_areas_plot,'YData',[1:length(probe_area_ids)]*dblVoxelSize,'CData',probe_area_ids(:));
	%set(sGUI.handles.axes_probe_areas,'YTick',probe_area_centers*dblVoxelSize,'YTickLabels',probe_area_labels);
	
	set(sGUI.handles.axes_probe_areas,'YTick',probe_area_boundaries(2:end)*dblVoxelSize,'YTickLabels',probe_area_full);
	set(sGUI.handles.axes_probe_areas,'YTickLabelRotation',70);
	
	yyaxis(sGUI.handles.axes_probe_areas2,'right');
	set(sGUI.handles.probe_areas_plot2,'YData',[1:length(probe_area_ids)]*dblVoxelSize,'CData',probe_area_ids(:));
	set(sGUI.handles.axes_probe_areas2,'YTick',probe_area_centers*dblVoxelSize,'YTickLabels',probe_area_labels);
	
	%save current data
	sGUI.output.probe_vector = probe_vector_cart;
	sGUI.output.probe_areas = probe_area_ids;
	sGUI.output.probe_intersect = vecLocationBrainIntersection;
	
	%% plot boundaries
	%extract boundaries
	matAreaColors = sGUI.cmap(probe_area_ids,:);
	vecBoundY = dblVoxelSize*find(~all(diff(matAreaColors,1,1) == 0,2));
	vecColor = [0.5 0.5 0.5 0.5];
	
	%plot
	cellHandleName = {'probe_clust_bounds','probe_zeta_bounds','probe_xcorr_bounds'};
	cellAxesHandles = {sGUI.handles.probe_clust,sGUI.handles.probe_zeta,sGUI.handles.probe_xcorr};
	for intPlot=1:numel(cellHandleName)
		delete(sGUI.handles.(cellHandleName{intPlot}));
		hAx = cellAxesHandles{intPlot};
		vecLimX = get(hAx,'xlim');
		boundary_lines = line(hAx,repmat(vecLimX,numel(vecBoundY),1)',repmat(vecBoundY,1,2)','Color',vecColor,'LineWidth',1);
		if intPlot==3
			boundary_lines2 = line(hAx,repmat(vecBoundY,1,2)',repmat(vecLimX,numel(vecBoundY),1)','Color',vecColor,'LineWidth',1);
			boundary_lines = cat(1,boundary_lines,boundary_lines2);
		end
		sGUI.handles.(cellHandleName{intPlot}) = boundary_lines;
	end
	
	% Upload gui_data
	guidata(hMain, sGUI);
	
	
	%% update slice
	PH_UpdateSlice(hMain);
	
end

