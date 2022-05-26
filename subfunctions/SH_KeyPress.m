function SH_KeyPress(hMain,eventdata)
	
	%{
	'\bf Image navigation: \rm' ...
	'Left arrow  : move to previous image' ...
	'Right arrow : move to next image' ...
	''...
	'\bf Set midline: \rm' ...
	'Ctrl + left click : set 1st point for midline' ...
	'2nd left click    : define midline' ...
	'Right click       : cancel' ...
	''...
	'\bf Add track: \rm' ...
	'Left click     : set 1st point for track' ...
	'2nd left click : define track' ...
	'Right click    : cancel' ...
	'' ...
	'\bf Remove/edit track: \rm' ...
	'Right click on track : open track menu' ...
	''...
	'\bf Other: \rm' ...
	'F5 : export slice data' ...
	'F9 : load slice data', ...
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
			SH_PlotPrepIms(hMain);
		end
	elseif strcmpi(eventdata.Key,'f1')
		%help
		SH_DisplaySlicePrepperControls();
	elseif strcmp(eventdata.Key,'x') || strcmp(eventdata.Key,'f5')
		%save
		SH_SaveSlicePrepperFile(hMain);
	elseif strcmp(eventdata.Key,'h') || strcmp(eventdata.Key,'f9')
		%load
		SH_LoadSliceData(hMain);
	elseif strcmp(eventdata.Key,'home')
		%move to beginning
		intCurrIm = sGUI.intCurrIm;
		if intCurrIm ~= 1
			%move slice
			sGUI.intCurrIm = 1;
			%update data
			guidata(hMain, sGUI);
			%plot images
			SH_PlotPrepIms(hMain);
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
			SH_PlotPrepIms(hMain);
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
			SH_PlotPrepIms(hMain);
		end
	else
		eventdata.Key
	end
	figure(sGUI.handles.hMain);
	
	%release
	sGUI = guidata(hMain);
	sGUI.IsBusy = false;
	guidata(hMain, sGUI);
end

