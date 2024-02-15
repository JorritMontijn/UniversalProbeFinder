function SH_FlipHorz(hMain,eventdata)
	
	% Get guidata
	sGUI = guidata(hMain);
	sGUI = guidata(sGUI.handles.hMain);
	hMain = sGUI.handles.hMain;
	if toc(sGUI.LastUpdate) < 0.1 || sGUI.IsBusy,return;end
	sGUI.LastUpdate = tic;
	sGUI.IsBusy = true;
	guidata(hMain, sGUI);
	
	%flip image
	intCurrIm = sGUI.intCurrIm;
	sGUI.sSliceData.Slice(intCurrIm).ImTransformed = fliplr(sGUI.sSliceData.Slice(intCurrIm).ImTransformed);
	guidata(hMain, sGUI);
	
	%redraw
	SH_PlotPrepIms(hMain);
	
	%release
	sGUI = guidata(hMain);
	sGUI.IsBusy = false;
	guidata(hMain, sGUI);
	
	%reset focus
	set(sGUI.handles.ptrButtonFlipHorz, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonFlipHorz, 'enable', 'on');
end