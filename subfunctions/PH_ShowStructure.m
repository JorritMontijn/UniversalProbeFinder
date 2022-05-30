function PH_ShowStructure(sGUI,eventdata)
	
	%% list structures at this downscaling level
	intStep = round(sGUI.sAtlas.Downsample)*2; %make this times 2 as it's rather expensive
	vecAreaIds = unique(sGUI.sAtlas.av(1:intStep:end,1:intStep:end,1:intStep:end));
	cellNames = lower(sGUI.sAtlas.st.name(vecAreaIds));
	[cellAlpabetical,vecReorder] = sort(cellNames);
	
	%% ask what to plot
	if ~any(strcmp(eventdata.Modifier,'alt'))
		%make alphabetical list
		vecPlotStructs = listdlg('Name','Area Selection','PromptString','Select an area to plot:', ...
			'ListString',cellAlpabetical,'ListSize',[520,500]);
		
		%retrieve ids
		vecPlotId = vecAreaIds(vecReorder(vecPlotStructs));
	else
		%search list
		strSearch = lower(inputdlg('Search areas'));
		vecListAreas = find(contains(lower(sGUI.sAtlas.st.name),strSearch));
		vecEligibleAreas = intersect(vecAreaIds,vecListAreas);
		if isempty(vecEligibleAreas)
			warndlg('No areas match your search string','No results')
		end
		
		vecPlotStructs = listdlg('Name','Area Selection','PromptString','Select an area to plot:', ...
			'ListString',sGUI.sAtlas.st.name(vecEligibleAreas),'ListSize',[520,500]);
		vecPlotId = vecEligibleAreas(vecPlotStructs);
	end
	
	%% plot area
	if isempty(vecPlotId),return;end
	
	for intIdIdx = 1:numel(vecPlotId)
		%get id
		intId = vecPlotId(intIdIdx);
		
		%shouldn't happen, but just to be sure
		if ~any(flat(sGUI.sAtlas.av(1:intStep:end,1:intStep:end,1:intStep:end)) == intId)
			warndlg(sprintf('%s does not appear in the atlas',sGUI.sAtlas.st.name{intId}),'Area not found')
			continue;
		end
		
		%add new structure to be plotted
		sGUI.structure_plot_idx(end+1) = intId;
		vecPlotCol = sGUI.sAtlas.ColorMap(intId,:);
		obj3D = isosurface(sGUI.sAtlas.av(1:intStep:end,1:intStep:end,1:intStep:end) == intId,0);
		
		if sGUI.transparency == 1
			dblAlpha = 0.4;
		else
			dblAlpha = 1;
		end
		sGUI.handles.structure_patch(end+1) = patch(sGUI.handles.hAxAtlas,'Vertices',obj3D.vertices(:,[2 1 3])*intStep, ...
			'Faces',obj3D.faces(:,[2 1 3]), ...
			'FaceColor',vecPlotCol,'EdgeColor','none','FaceAlpha',dblAlpha);
	end
	
	%update data
	guidata(sGUI.handles.hMain, sGUI);
end