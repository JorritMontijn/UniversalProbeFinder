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
	if toc(sGUI.LastUpdate) < 0.1 || sGUI.IsBusy,return;end
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
		%update data
		guidata(hMain, sGUI);
	elseif strcmpi(eventdata.Key,'f3')
		%toggle overlay type
		if sGUI.OverlayType == 1
			sGUI.OverlayType = 2;
		elseif sGUI.OverlayType == 2
			sGUI.OverlayType = 1;
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
	elseif strcmp(eventdata.Key,'i') || strcmp(eventdata.Key,'k')
		%stretch/shrink
	else
		%to do: rotation


		%to do: copy/paste
		eventdata.Key
	end
	figure(sGUI.handles.hMain);
	
	%release
	sGUI = guidata(hMain);
	sGUI.IsBusy = false;
	guidata(hMain, sGUI);
end

