function PH_KeyPress(hMain,eventdata)
	
	%dummy for testing
	if ~exist('eventdata','var')
		eventdata = struct;
		eventdata.Key = 'uparrow';
		eventdata.Modifier = [];
	end
	
	% Get guidata
	sGUI = guidata(hMain);
	if toc(sGUI.lastPress) < 0.1;return;end
	sGUI.lastPress = tic;
	guidata(hMain, sGUI);
	dblBaseStep = 10;
	
	if strcmp(eventdata.Key,'uparrow') || strcmp(eventdata.Key,'downarrow')
		dblSign = double(strcmp(eventdata.Key,'downarrow'))*2-1;
		dblStep = sGUI.step_size;
		if isempty(eventdata.Modifier)
			% Up: move probe anterior
			dblMoveAP = dblBaseStep*dblSign*dblStep;
			vecSphereVector = PH_CartVec2SphVec(PH_GetProbeVector(hMain));
			vecNewSphereVector = vecSphereVector - [0 dblMoveAP 0 0 0 0];
			PH_UpdateProbeCoordinates(hMain,vecNewSphereVector)
		elseif any(strcmp(eventdata.Modifier,'shift'))
			% Shift-up: increase AP angle
			dblRotateAP = dblSign*dblStep;
			vecSphereVector = PH_CartVec2SphVec(PH_GetProbeVector(hMain));
			vecNewSphereVector = vecSphereVector + [0 0 0 0 dblRotateAP 0];
			PH_UpdateProbeCoordinates(hMain,vecNewSphereVector)
		elseif any(strcmp(eventdata.Modifier,'alt'))
			% Alt-up: raise probe
			dblMoveUpDown = dblBaseStep*dblSign*dblStep;
			vecCartOld = PH_GetProbeVector(hMain);
			vecDelta = diff(vecCartOld,[],1)./ ...
				norm(diff(vecCartOld,[],1))*dblMoveUpDown;
			vecCartNew = bsxfun(@minus,vecCartOld,vecDelta);
			
			PH_UpdateProbeCoordinates(hMain,PH_CartVec2SphVec(vecCartNew));
		end
		
	elseif strcmp(eventdata.Key,'rightarrow') || strcmp(eventdata.Key,'leftarrow')
		dblSign = double(strcmp(eventdata.Key,'rightarrow'))*2-1;
		dblStep = sGUI.step_size;
		if isempty(eventdata.Modifier)
			% Right: move probe right
			dblMoveML = dblBaseStep*dblSign*dblStep;
			vecSphereVector = PH_CartVec2SphVec(PH_GetProbeVector(hMain));
			vecNewSphereVector = vecSphereVector - [dblMoveML 0 0 0 0 0];
			PH_UpdateProbeCoordinates(hMain,vecNewSphereVector)
		elseif any(strcmp(eventdata.Modifier,'shift'))
			% Ctrl-right: increase vertical angle
			dblRotateML = dblSign*dblStep;
			vecSphereVector = PH_CartVec2SphVec(PH_GetProbeVector(hMain));
			vecNewSphereVector = vecSphereVector - [0 0 0 dblRotateML 0 0];
			PH_UpdateProbeCoordinates(hMain,vecNewSphereVector)
		elseif any(strcmp(eventdata.Modifier,'alt'))
			% Alt-left: shrink probe
			dblShrinkGrow = dblSign*dblStep*0.01;
			vecSphereVector = PH_CartVec2SphVec(PH_GetProbeVector(hMain));
			vecNewSphereVector = vecSphereVector + [0 0 0 0 0 dblShrinkGrow*vecSphereVector(6)];
			PH_UpdateProbeCoordinates(hMain,vecNewSphereVector);
		end
		
	elseif strcmp(eventdata.Key,'f1')
		
		% Bring up controls again
		PH_DisplayControls;
		
	elseif strcmp(eventdata.Key,'b')
		% Toggle brain outline visibility
		current_visibility = sGUI.handles.cortex_outline.Visible;
		switch current_visibility; case 'on'; new_visibility = 'off'; case 'off'; new_visibility = 'on'; end;
		set(sGUI.handles.cortex_outline,'Visible',new_visibility);
		guidata(hMain, sGUI);
		
	elseif strcmp(eventdata.Key,'a')
		% Toggle plotted structure visibility
		if ~isempty(sGUI.structure_plot_idx)
			current_visibility = get(sGUI.handles.structure_patch(1),'Visible');
			switch current_visibility; case 'on'; new_visibility = 'off'; case 'off'; new_visibility = 'on'; end;
			set(sGUI.handles.structure_patch,'Visible',new_visibility);
			guidata(hMain, sGUI);
		end
		
	elseif strcmp(eventdata.Key,'s')
		% Toggle slice volume/visibility
		slice_volumes = {'tv','av','none'};
		new_slice_volume = slice_volumes{circshift( ...
			strcmp(sGUI.handles.slice_volume,slice_volumes),[0,1])};
		
		if strcmp(new_slice_volume,'none')
			set(sGUI.handles.slice_plot,'Visible','off');
		else
			set(sGUI.handles.slice_plot,'Visible','on');
		end
		
		sGUI.handles.slice_volume = new_slice_volume;
		guidata(hMain, sGUI);
		
		PH_UpdateSlice(hMain);
		
	elseif strcmp(eventdata.Key,'p')
		% Toggle probe visibility
		current_visibility = sGUI.handles.probe_vector_cart.Visible;
		switch current_visibility; case 'on'; new_visibility = 'off'; case 'off'; new_visibility = 'on'; end;
		set(sGUI.handles.probe_vector_cart,'Visible',new_visibility);
		guidata(hMain, sGUI);
		
	elseif strcmp(eventdata.Key,'m')
		% Set probe angle
		PH_SetProbePosition(hMain);
		
	elseif strcmp(eventdata.Key,'equal') || strcmp(eventdata.Key,'add')
		% Add structure(s) to display
		slice_spacing = 10;
		
		% Prompt for which structures to show (only structures which are
		% labelled in the slice-spacing downsampled annotated volume)
		
		if any(strcmp(eventdata.Modifier,'shift'))
			%increase step size
			sGUI.step_size = sGUI.step_size/0.9;
			guidata(hMain, sGUI);
			vecSphereVector = PH_CartVec2SphVec(PH_GetProbeVector(hMain));
			PH_UpdateProbeCoordinates(hMain,vecSphereVector);
			
		elseif any(strcmp(eventdata.Modifier,'control'))
			% (shift: use hierarchy search)
			plot_structures = hierarchicalSelect(sGUI.sAtlas.st);
			
			if ~isempty(plot_structures) % will be empty if dialog was cancelled
				% get all children of this one
				thisID = sGUI.sAtlas.st.id(plot_structures);
				idStr = sprintf('/%d/', thisID);
				theseCh = find(cellfun(@(x)contains(x,idStr), sGUI.sAtlas.st.structure_id_path));
				
				% plot the structure
				slice_spacing = 5;
				plot_structure_color = hex2dec(reshape(sGUI.sAtlas.st.color_hex_triplet{plot_structures},3,[]))./255;
				structure_3d = isosurface(permute(ismember(sGUI.sAtlas.av(1:slice_spacing:end, ...
					1:slice_spacing:end,1:slice_spacing:end),theseCh),[3,1,2]),0);
				
				structure_alpha = 0.2;
				sGUI.structure_plot_idx(end+1) = plot_structures;
				sGUI.handles.structure_patch(end+1) = patch('Vertices',structure_3d.vertices*slice_spacing, ...
					'Faces',structure_3d.faces, ...
					'FaceColor',plot_structure_color,'EdgeColor','none','FaceAlpha',structure_alpha);
				guidata(hMain, sGUI);
			end
			
		else
			% (no shift/control: list in native CCF order)
			parsed_structures = unique(reshape(sGUI.sAtlas.av(1:slice_spacing:end, ...
				1:slice_spacing:end,1:slice_spacing:end),[],1));
			
			if ~any(strcmp(eventdata.Modifier,'alt'))
				% (no alt: list all)
				plot_structures_parsed = listdlg('PromptString','Select a structure to plot:', ...
					'ListString',sGUI.sAtlas.st.safe_name(parsed_structures),'ListSize',[520,500]);
				plot_structures = parsed_structures(plot_structures_parsed);
			else
				% (alt: search list)
				structure_search = lower(inputdlg('Search structures'));
				structure_match = find(contains(lower(sGUI.sAtlas.st.safe_name),structure_search));
				list_structures = intersect(parsed_structures,structure_match);
				if isempty(list_structures)
					error('No structure search results')
				end
				
				plot_structures_parsed = listdlg('PromptString','Select a structure to plot:', ...
					'ListString',sGUI.sAtlas.st.safe_name(list_structures),'ListSize',[520,500]);
				plot_structures = list_structures(plot_structures_parsed);
			end
			
			if ~isempty(plot_structures)
				for curr_plot_structure = reshape(plot_structures,1,[])
					% If this label isn't used, don't plot
					if ~any(reshape(sGUI.sAtlas.av( ...
							1:slice_spacing:end,1:slice_spacing:end,1:slice_spacing:end),[],1) == curr_plot_structure)
						disp(['"' sGUI.sAtlas.st.safe_name{curr_plot_structure} '" is not parsed in the atlas'])
						continue
					end
					
					sGUI.structure_plot_idx(end+1) = curr_plot_structure;
					
					plot_structure_color = hex2dec(reshape(sGUI.sAtlas.st.color_hex_triplet{curr_plot_structure},2,[])')./255;
					structure_3d = isosurface(sGUI.sAtlas.av(1:slice_spacing:end, ...
						1:slice_spacing:end,1:slice_spacing:end) == curr_plot_structure,0);
					
					structure_alpha = 0.2;
					sGUI.handles.structure_patch(end+1) = patch('Vertices',structure_3d.vertices(:,[2 1 3])*slice_spacing, ...
						'Faces',structure_3d.faces(:,[2 1 3]), ...
						'FaceColor',plot_structure_color,'EdgeColor','none','FaceAlpha',structure_alpha);
				end
				guidata(hMain, sGUI);
				
			end
		end
		
	elseif strcmp(eventdata.Key,'hyphen') || strcmp(eventdata.Key,'subtract')
		if any(strcmp(eventdata.Modifier,'shift'))
			%decrease step size
			sGUI.step_size = sGUI.step_size*0.9;
			guidata(hMain, sGUI);
			vecSphereVector = PH_CartVec2SphVec(PH_GetProbeVector(hMain));
			PH_UpdateProbeCoordinates(hMain,vecSphereVector);
		
		else
			% Remove structure(s) already plotted
			if ~isempty(sGUI.structure_plot_idx)
				remove_structures = listdlg('PromptString','Select a structure to remove:', ...
					'ListString',sGUI.sAtlas.st.safe_name(sGUI.structure_plot_idx));
				delete(sGUI.handles.structure_patch(remove_structures))
				sGUI.structure_plot_idx(remove_structures) = [];
				sGUI.handles.structure_patch(remove_structures) = [];
				guidata(hMain, sGUI);
			end
		end
		
	elseif strcmp(eventdata.Key,'x')
		PH_SaveProbeFile(hMain);
	elseif strcmp(eventdata.Key,'h')
		% Load probe histology points, plot line of best fit
		PH_LoadProbeLocation(hMain);
	end
end

