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
		strShowBrain = sGUI.handles.cortex_outline.Visible;
		if strcmpi(strShowBrain,'on')
			strNewSwitch = 'off'; 
		elseif strcmpi(strShowBrain,'off')
			strNewSwitch = 'on'; 
		end
		set(sGUI.handles.cortex_outline,'Visible',strNewSwitch);
		guidata(hMain, sGUI);
		
	elseif strcmp(eventdata.Key,'t')
		dblAlphaValueSlice = 0.65;
		dblAlphaValueVolumes = 0.4;
		
		
		%switch
		if sGUI.transparency == 0
			sGUI.transparency = 1;
			sGUI.handles.slice_plot.FaceAlpha = dblAlphaValueSlice;
			for intObject=1:numel(sGUI.handles.structure_patch)
				set(sGUI.handles.structure_patch(intObject),'FaceAlpha',dblAlphaValueVolumes);
			end
		else
			sGUI.transparency = 0;
			sGUI.handles.slice_plot.FaceAlpha = 1;
			for intObject=1:numel(sGUI.handles.structure_patch)
				set(sGUI.handles.structure_patch(intObject),'FaceAlpha',1);
			end
		end
		
		%update
		guidata(hMain, sGUI);
		
	elseif strcmp(eventdata.Key,'a')
		% Toggle plotted structure visibility
		if ~isempty(sGUI.structure_plot_idx)
			strShowArea = get(sGUI.handles.structure_patch(1),'Visible');
			if strcmpi(strShowArea,'on')
				strNewSwitch = 'off';
			elseif strcmpi(strShowArea,'off')
				strNewSwitch = 'on';
			end
			set(sGUI.handles.structure_patch,'Visible',strNewSwitch);
			guidata(hMain, sGUI);
		end
		
	elseif strcmp(eventdata.Key,'s')
		% Toggle slice volume/visibility
		cellSliceTypes = {'tv','av','none'};
		strSliceType = cellSliceTypes{circshift( ...
			strcmp(sGUI.handles.slice_volume,cellSliceTypes),[0,1])};
		
		if strcmp(strSliceType,'none')
			set(sGUI.handles.slice_plot,'Visible','off');
		else
			set(sGUI.handles.slice_plot,'Visible','on');
		end
		
		sGUI.handles.slice_volume = strSliceType;
		guidata(hMain, sGUI);
		
		PH_UpdateSlice(hMain);
		
	elseif strcmp(eventdata.Key,'p')
		% Toggle probe visibility
		strShowProbe = sGUI.handles.probe_vector_cart.Visible;
		if strcmpi(strShowProbe,'on')
			strNewSwitch = 'off';
		elseif strcmpi(strShowProbe,'off')
			strNewSwitch = 'on';
		end
		set(sGUI.handles.probe_vector_cart,'Visible',strNewSwitch);
		guidata(hMain, sGUI);
		
	elseif strcmp(eventdata.Key,'m')
		% Set probe angle
		PH_SetProbePosition(hMain);
		
	elseif strcmp(eventdata.Key,'equal') || strcmp(eventdata.Key,'add')
		if any(strcmp(eventdata.Modifier,'shift'))
			%increase step size
			sGUI.step_size = sGUI.step_size/0.9;
			guidata(hMain, sGUI);
			vecSphereVector = PH_CartVec2SphVec(PH_GetProbeVector(hMain));
			PH_UpdateProbeCoordinates(hMain,vecSphereVector);
		else
			%relay to subfunction
			PH_ShowStructure(sGUI,eventdata);
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
				vecRemAreas = listdlg('PromptString','Select an area to remove:', ...
					'ListString',sGUI.sAtlas.st.name(sGUI.structure_plot_idx));
				delete(sGUI.handles.structure_patch(vecRemAreas))
				sGUI.structure_plot_idx(vecRemAreas) = [];
				sGUI.handles.structure_patch(vecRemAreas) = [];
				guidata(hMain, sGUI);
			end
		end
		
	elseif strcmp(eventdata.Key,'x') || strcmp(eventdata.Key,'f5')
		PH_SaveProbeFile(hMain);
	elseif strcmp(eventdata.Key,'h') || strcmp(eventdata.Key,'f9')
		% Load probe histology points, plot line of best fit
		PH_LoadProbeLocation(hMain);
	end
end

