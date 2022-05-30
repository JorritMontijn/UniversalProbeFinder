function SF_KeyPress(hMain,eventdata)
	
	%{
		'\bf Image navigation: \rm' ...
		'Left/right arrow  : move to previous/next image' ...
		'Page up/down      : move forward/back by five' ...
		'Home/end          : move to first/last image' ...
		''...
		'\bf Adjust slice rotation: \rm' ...
		'q/e : roll clockwise/counter-clockwise' ...
		'w/s : pitch down/up' ...
		'a/d : yaw left/right' ...
		''...
		'\bf Adjust slice position and size: \rm' ...
		'i/k : DV, move up/down' ...
		'j/l : ML, move left/right' ...
		'h/n : AP, move forward/back' ...
		'shift + i/k : stretch/shrink vertically' ...
		'shift + j/l : stretch/shrink horizontally' ...
		''...
		'\bf Copy/paste slice rotation+position: \rm' ...
		'c : copy settings of current slice' ...
		'v : paste previously copied settings to slice' ...
		'b : interpolate slices between last two copied slices'...
		''...
		'\bf Other: \rm' ...
		'x  : export data for ProbeFinder'...
		'F5 : save data' ...
		'F9 : load data', ...
		'F1 : bring up this window'}, ...
	%}
	
	%dummy for testing
	if ~exist('eventdata','var')
		eventdata = struct;
		eventdata.Key = 'uparrow';
		eventdata.Modifier = [];
	end
	
	% Get guidata
	sGUI = guidata(hMain);
	hMain = sGUI.handles.hMain;
	if sGUI.IsBusy,return;end
	sGUI.LastUpdate = tic;
	sGUI.IsBusy = true;
	guidata(hMain, sGUI);
	sSliceData = sGUI.sSliceData;
	dblStep = sGUI.StepSize;
	
	if strcmp(eventdata.Key,'leftarrow') || strcmp(eventdata.Key,'rightarrow')
		%change current image
		dblSign = double(strcmp(eventdata.Key,'rightarrow'))*2-1;
		intCurrIm = sGUI.intCurrIm + dblSign;
		if intCurrIm < 1 || intCurrIm > numel(sSliceData.Slice)
			%ignore
		else
			sGUI.intCurrIm = intCurrIm;
			%update data
			guidata(hMain, sGUI);
			%plot images
			SF_PlotIms(hMain);
		end
	elseif strcmpi(eventdata.Key,'f1')
		%help
		SF_DisplaySliceFinderControls();
		return;
	elseif strcmpi(eventdata.Key,'f2')
		%invert axes
		sGUI.AxesSign = -sGUI.AxesSign;
		if sGUI.AxesSign == 1
			sGUI.handles.ptrTextMessages.String = sprintf('Controls are now slice-centered');
		else
			sGUI.handles.ptrTextMessages.String = sprintf('Controls are now atlas-centered');
		end
		%update data
		guidata(hMain, sGUI);
	elseif strcmpi(eventdata.Key,'f3')
		%toggle overlay type
		if sGUI.OverlayType == 0
			sGUI.OverlayType = 1;
		elseif sGUI.OverlayType == 1
			sGUI.OverlayType = 2;
		elseif sGUI.OverlayType == 2
			sGUI.OverlayType = 0;
		end
		
		%update data
		guidata(hMain, sGUI);
		
		%redraw
		SF_PlotSliceInAtlas(hMain);
	elseif strcmp(eventdata.Key,'f5')
		SF_SaveSliceFinderFile(hMain);
	elseif strcmp(eventdata.Key,'x')
		%save
		SF_ExportSliceFinderFile(hMain);
	elseif strcmp(eventdata.Key,'f9')
		%load
		SF_LoadSliceFinderFile(hMain);
	elseif strcmp(eventdata.Key,'home')
		%move to beginning
		intCurrIm = sGUI.intCurrIm;
		if intCurrIm ~= 1
			%move slice
			sGUI.intCurrIm = 1;
			%update data
			guidata(hMain, sGUI);
			%plot images
			SF_PlotIms(hMain);
		end
	elseif strcmp(eventdata.Key,'end')
		%move to end
		intCurrIm = sGUI.intCurrIm;
		if intCurrIm ~= numel(sSliceData.Slice)
			%move slice
			sGUI.intCurrIm = numel(sSliceData.Slice);
			%update data
			guidata(hMain, sGUI);
			%plot images
			SF_PlotIms(hMain);
		end
	elseif strcmp(eventdata.Key,'pageup') || strcmp(eventdata.Key,'pagedown')
		%change current image
		dblSign = (double(strcmp(eventdata.Key,'pagedown'))*2-1)*5;
		intCurrIm = sGUI.intCurrIm + dblSign;
		if intCurrIm < 1
			intCurrIm = 1;
		elseif intCurrIm > numel(sSliceData.Slice)
			intCurrIm = numel(sSliceData.Slice);
		end
		
		if sGUI.intCurrIm ~= intCurrIm
			sGUI.intCurrIm = intCurrIm;
			%update data
			guidata(hMain, sGUI);
			%plot images
			SF_PlotIms(hMain);
		end
	elseif strcmp(eventdata.Key,'j') || strcmp(eventdata.Key,'l')
		%move ML
		dblSign = (double(strcmp(eventdata.Key,'l'))*2-1);
		if strcmpi(eventdata.Modifier,'shift')
			%stretch
			dblShrinkGrow = dblSign*dblStep*0.01;
			sGUI.sSliceData.Slice(sGUI.intCurrIm).ResizeLeftRight = sGUI.sSliceData.Slice(sGUI.intCurrIm).ResizeLeftRight + ...
				sGUI.sSliceData.Slice(sGUI.intCurrIm).ResizeLeftRight*dblShrinkGrow;
		else
			%move
			dblMoveML = sGUI.AxesSign*dblSign*dblStep*10;
			sGUI.sSliceData.Slice(sGUI.intCurrIm).Center(1) = sGUI.sSliceData.Slice(sGUI.intCurrIm).Center(1) + dblMoveML;
		end
		%update data & redraw
		guidata(hMain,sGUI);
		SF_PlotSliceInAtlas(hMain);
	elseif strcmp(eventdata.Key,'h') || strcmp(eventdata.Key,'n')
		%move AP
		dblSign = (double(strcmp(eventdata.Key,'h'))*2-1);
		dblMoveAP = dblSign*dblStep*10;
		sGUI.sSliceData.Slice(sGUI.intCurrIm).Center(2) = sGUI.sSliceData.Slice(sGUI.intCurrIm).Center(2) + dblMoveAP;
		
		%update data & redraw
		guidata(hMain,sGUI);
		SF_PlotSliceInAtlas(hMain);
	elseif strcmp(eventdata.Key,'i') || strcmp(eventdata.Key,'k')
		%move DV or stretch
		dblSign = (double(strcmp(eventdata.Key,'k'))*2-1);
		if strcmpi(eventdata.Modifier,'shift')
			%stretch
			dblShrinkGrow = dblSign*dblStep*0.01;
			sGUI.sSliceData.Slice(sGUI.intCurrIm).ResizeUpDown = sGUI.sSliceData.Slice(sGUI.intCurrIm).ResizeUpDown + ...
				sGUI.sSliceData.Slice(sGUI.intCurrIm).ResizeUpDown*dblShrinkGrow;
		else
			%move
			dblMoveDV = sGUI.AxesSign*dblSign*dblStep*10;
			sGUI.sSliceData.Slice(sGUI.intCurrIm).Center(3) = sGUI.sSliceData.Slice(sGUI.intCurrIm).Center(3) + dblMoveDV;
		end
		%update data & redraw
		guidata(hMain,sGUI);
		SF_PlotSliceInAtlas(hMain);
	elseif strcmp(eventdata.Key,'c') && ~isempty(eventdata.Modifier) && strcmpi(eventdata.Modifier,'control')
		%copy details
		sGUI.PrevCopy = sGUI.CurrCopy;
		sGUI.CurrCopy = sGUI.intCurrIm;
		sGUI.handles.ptrTextClipboard.String = sprintf('Curr copy: %d - Prev copy: %d',sGUI.CurrCopy,sGUI.PrevCopy);
		%update data
		guidata(hMain,sGUI);
	elseif strcmp(eventdata.Key,'v') && ~isempty(eventdata.Modifier) && strcmpi(eventdata.Modifier,'control')
		%paste details
		if ~(isnan(sGUI.CurrCopy) || isempty(sGUI.CurrCopy) || isnan(sGUI.intCurrIm) || isempty(sGUI.intCurrIm))
			%backup
			sGUI.CopyIms = sGUI.intCurrIm;
			sGUI.sCopyBackup = struct;
			sGUI.sCopyBackup.Center = sGUI.sSliceData.Slice(sGUI.intCurrIm).Center;
			sGUI.sCopyBackup.RotateAroundML = sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundML;
			sGUI.sCopyBackup.RotateAroundDV = sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundDV;
			sGUI.sCopyBackup.RotateAroundAP = sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundAP;
			
			%copy location
			sGUI.sSliceData.Slice(sGUI.intCurrIm).Center = sGUI.sSliceData.Slice(sGUI.CurrCopy).Center;
			
			sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundML = sGUI.sSliceData.Slice(sGUI.CurrCopy).RotateAroundML;
			sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundDV = sGUI.sSliceData.Slice(sGUI.CurrCopy).RotateAroundDV;
			sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundAP = sGUI.sSliceData.Slice(sGUI.CurrCopy).RotateAroundAP;
			
			%update data
			guidata(hMain,sGUI);
			
			%redraw
			SF_PlotSliceInAtlas(hMain);
			
			%message
			sGUI.handles.ptrTextMessages.String = sprintf('Copied rotation/location from Im%d to Im%d',sGUI.CurrCopy,sGUI.intCurrIm);
			
		end
	elseif strcmp(eventdata.Key,'b') && ~isempty(eventdata.Modifier) && strcmpi(eventdata.Modifier,'control')
		%interpolate details
		%paste details
		if ~(isnan(sGUI.CurrCopy) || isempty(sGUI.CurrCopy) || isnan(sGUI.PrevCopy) || (abs(sGUI.PrevCopy - sGUI.CurrCopy) < 2))
			%copy location 1
			vecC1 = sGUI.sSliceData.Slice(sGUI.CurrCopy).Center;
			dblR_ML1 = sGUI.sSliceData.Slice(sGUI.CurrCopy).RotateAroundML;
			dblR_DV1 = sGUI.sSliceData.Slice(sGUI.CurrCopy).RotateAroundDV;
			dblR_AP1 = sGUI.sSliceData.Slice(sGUI.CurrCopy).RotateAroundAP;
			
			%copy location 2
			vecC2 = sGUI.sSliceData.Slice(sGUI.PrevCopy).Center;
			dblR_ML2 = sGUI.sSliceData.Slice(sGUI.PrevCopy).RotateAroundML;
			dblR_DV2 = sGUI.sSliceData.Slice(sGUI.PrevCopy).RotateAroundDV;
			dblR_AP2 = sGUI.sSliceData.Slice(sGUI.PrevCopy).RotateAroundAP;
			
			%create interpolation
			intP = abs(sGUI.PrevCopy - sGUI.CurrCopy)+1;
			vecApplyIms = linspace(sGUI.CurrCopy,sGUI.PrevCopy,intP);
			vecC_ML = linspace(vecC1(1),vecC2(1),intP);
			vecC_DV = linspace(vecC1(2),vecC2(2),intP);
			vecC_AP = linspace(vecC1(3),vecC2(3),intP);
			
			dblDiffR_ML = rad2deg(circ_dist(deg2rad(dblR_ML1),deg2rad(dblR_ML2)));
			if dblR_ML1 < dblR_ML2,dblDiffR_ML=-dblDiffR_ML;end
			dblDiffR_DV = rad2deg(circ_dist(deg2rad(dblR_DV1),deg2rad(dblR_DV2)));
			if dblR_DV1 < dblR_DV2,dblDiffR_DV=-dblDiffR_DV;end
			dblDiffR_AP = rad2deg(circ_dist(deg2rad(dblR_AP1),deg2rad(dblR_AP2)));
			if dblR_AP1 < dblR_AP2,dblDiffR_AP=-dblDiffR_AP;end
			vecR_ML = mod(dblR_ML1+linspace(0,dblDiffR_ML,intP),360);
			vecR_DV = mod(dblR_DV1+linspace(0,dblDiffR_DV,intP),360);
			vecR_AP = mod(dblR_AP1+linspace(0,dblDiffR_AP,intP),360);
			
			%backup slices
			sGUI.CopyIms = vecApplyIms;
			sGUI.sCopyBackup = struct;
			
			%apply
			for intIdx = 1:numel(vecApplyIms)
				intApplyIm = vecApplyIms(intIdx);
				
				%backup
				sGUI.sCopyBackup(intIdx).Center = sGUI.sSliceData.Slice(intApplyIm).Center;
				sGUI.sCopyBackup(intIdx).RotateAroundML = sGUI.sSliceData.Slice(intApplyIm).RotateAroundML;
				sGUI.sCopyBackup(intIdx).RotateAroundDV = sGUI.sSliceData.Slice(intApplyIm).RotateAroundDV;
				sGUI.sCopyBackup(intIdx).RotateAroundAP = sGUI.sSliceData.Slice(intApplyIm).RotateAroundAP;
				
				%apply
				sGUI.sSliceData.Slice(intApplyIm).Center(1) = vecC_ML(intIdx);
				sGUI.sSliceData.Slice(intApplyIm).Center(2) = vecC_DV(intIdx);
				sGUI.sSliceData.Slice(intApplyIm).Center(3) = vecC_AP(intIdx);
				sGUI.sSliceData.Slice(intApplyIm).RotateAroundML = vecR_ML(intIdx);
				sGUI.sSliceData.Slice(intApplyIm).RotateAroundDV = vecR_DV(intIdx);
				sGUI.sSliceData.Slice(intApplyIm).RotateAroundAP = vecR_AP(intIdx);
			end
			
			%update data
			guidata(hMain,sGUI);
			
			%redraw
			SF_PlotSliceInAtlas(hMain);
			
			%message
			sGUI.handles.ptrTextMessages.String = sprintf('Interpolated between Im%d and Im%d',sGUI.CurrCopy,sGUI.PrevCopy);
			
		end
	elseif strcmp(eventdata.Key,'t')
		%transparency
		dblAlphaValueSlice = 0.8;
		dblAlphaValueVolumes = 0.4;
		
		%switch
		if sGUI.transparency == 0
			sGUI.transparency = 1;
			sGUI.handles.hSliceInAtlas.FaceAlpha = dblAlphaValueSlice;
			for intObject=1:numel(sGUI.handles.structure_patch)
				set(sGUI.handles.structure_patch(intObject),'FaceAlpha',dblAlphaValueVolumes);
			end
		else
			sGUI.transparency = 0;
			sGUI.handles.hSliceInAtlas.FaceAlpha = 1;
			for intObject=1:numel(sGUI.handles.structure_patch)
				set(sGUI.handles.structure_patch(intObject),'FaceAlpha',1);
			end
		end
		
		%update
		guidata(hMain, sGUI);
	elseif strcmp(eventdata.Key,'z')  && ~isempty(eventdata.Modifier) && strcmpi(eventdata.Modifier,'control')
		%undo
		if ~isempty(sGUI.CopyIms) && ~any(isnan(sGUI.CopyIms))
			vecReset = sGUI.CopyIms;
			for intImIdx=1:numel(vecReset)
				intIm = vecReset(intImIdx);
				
				sGUI.sSliceData.Slice(intIm).Center = sGUI.sCopyBackup(intImIdx).Center;
				sGUI.sSliceData.Slice(intIm).RotateAroundML = sGUI.sCopyBackup(intImIdx).RotateAroundML;
				sGUI.sSliceData.Slice(intIm).RotateAroundDV = sGUI.sCopyBackup(intImIdx).RotateAroundDV;
				sGUI.sSliceData.Slice(intIm).RotateAroundAP = sGUI.sCopyBackup(intImIdx).RotateAroundAP;
			end
			sGUI.CopyIms = [];
			
			%update data
			guidata(hMain,sGUI);
			
			%redraw
			SF_PlotSliceInAtlas(hMain);
			
			%message
			sGUI.handles.ptrTextMessages.String = sprintf('Reversed copy/paste');
		end
	elseif strcmp(eventdata.Key,'w') || strcmp(eventdata.Key,'s')
		%pitch; rotate around ML
		dblSign = (double(strcmp(eventdata.Key,'w'))*2-1);
		dblPitchML = dblSign*dblStep;
		sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundML = mod(sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundML + dblPitchML,360);
		
		%update data & redraw
		guidata(hMain,sGUI);
		SF_PlotSliceInAtlas(hMain);
	elseif strcmp(eventdata.Key,'q') || strcmp(eventdata.Key,'e')
		%roll; rotate around AP
		dblSign = (double(strcmp(eventdata.Key,'q'))*2-1)*sGUI.AxesSign;
		dblRollAP = dblSign*dblStep;
		sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundAP = mod(sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundAP + dblRollAP,360);
		
		%update data & redraw
		guidata(hMain,sGUI);
		SF_PlotSliceInAtlas(hMain);
	elseif strcmp(eventdata.Key,'a') || strcmp(eventdata.Key,'d')
		%yaw; rotate around DV
		dblSign = (double(strcmp(eventdata.Key,'a'))*2-1);
		dblYawDV = dblSign*dblStep;
		sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundDV = mod(sGUI.sSliceData.Slice(sGUI.intCurrIm).RotateAroundDV + dblYawDV,360);
		
		%update data & redraw
		guidata(hMain,sGUI);
		SF_PlotSliceInAtlas(hMain);
	elseif strcmp(eventdata.Key,'equal') || strcmp(eventdata.Key,'add')
		if any(strcmp(eventdata.Modifier,'shift'))
			%increase step size
			sGUI.StepSize = sGUI.StepSize/0.9;
			guidata(hMain, sGUI);
			
			%message
			sGUI.handles.ptrTextMessages.String = sprintf('Step size is now %d%%',round(sGUI.StepSize*100));
		else
			%relay to subfunction
			PH_ShowStructure(sGUI,eventdata);
		end
	elseif strcmp(eventdata.Key,'hyphen') || strcmp(eventdata.Key,'subtract')
		if any(strcmp(eventdata.Modifier,'shift'))
			%decrease step size
			sGUI.StepSize = sGUI.StepSize*0.9;
			guidata(hMain, sGUI);
			
			%message
			sGUI.handles.ptrTextMessages.String = sprintf('Step size is now %d%%',round(sGUI.StepSize*100));
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
	end
	figure(sGUI.handles.hMain);
	
	%release
	sGUI = guidata(hMain);
	sGUI.IsBusy = false;
	guidata(hMain, sGUI);
end

