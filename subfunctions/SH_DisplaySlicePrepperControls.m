function SH_DisplaySlicePrepperControls(hObject,varargin)
	
	%check if help is already open
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	if ~isempty(sGUI.handles.hDispHelp) && ishandle(sGUI.handles.hDispHelp)
		figure(sGUI.handles.hDispHelp);return;
	end
	
	% Print controls
	CreateStruct.Interpreter = 'tex';
	CreateStruct.WindowStyle = 'non-modal';
	cellTxt = {''...
		'\fontsize{12}Tip: if the keyboard controls stop working after you press a button, click somewhere in the header area to return focus to the GUI.' ...
		'' ...
		'\bf Image navigation: \rm' ...
		'Left/right arrow  : move to previous/next image' ...
		'Shift + L/R arrow : swap with previous/next image' ...
		'Page up/down      : move forward/back by five' ...
		'Home/end          : move to first/last image' ...
		''...
		'\bf Set midline: \rm' ...
		'Ctrl + left click : set 1st point for midline' ...
		'2nd left click    : finish midline' ...
		'Right click       : cancel' ...
		''...
		'\bf Add trajectory: \rm' ...
		'Left click     : set 1st point for trajectory' ...
		'2nd left click : finish trajectory' ...
		'Right click    : cancel' ...
		'' ...
		'\bf Delete trajectory: \rm' ...
		'Right click on trajectory : open menu, then delete' ...
		''...
		'\bf Other: \rm' ...
		'F5 or x : export data' ...
		'F9 or h : load data', ...
		'F1      : bring up this window'};
	hMsgBox = msgbox( ...
		cellTxt, ...
		'Controls',CreateStruct);
	
	%add handles & return to hMsgBox
	hRealMain = sGUI.handles.hMain;
	sMiniGUI = struct;
	sMiniGUI.hMain = hRealMain;
	sMiniGUI.handles = sGUI.handles;
	guidata(hMsgBox,sMiniGUI);
	set(hMsgBox,'KeyPressFcn',@SH_KeyPress);
	set(hMsgBox,'DeleteFcn',@PH_DeleteHelpFcn);
	
	%add link to manual
	vecPos = [0 (1 - 1/numel(cellTxt)) 1 1/numel(cellTxt)];
	hAx = axes(hMsgBox,'Position',vecPos);
	axis(hAx,'off');
	hTxt = text(hAx,0.9,0.5,'$\mathrm{\underline{Manual}}$',...
		'color',[0 0 .8],'FontSize',12,'Interpreter','latex',...
		'HorizontalAlignment','right');
	hTxt.ButtonDownFcn = @(~,~)web('https://github.com/JorritMontijn/UniversalProbeFinder/blob/main/UserGuide_UniversalProbeFinder.pdf'); % this opens the website
	
	%reset focus
	set(sGUI.handles.ptrButtonHelp, 'enable', 'off');
	drawnow;
	set(sGUI.handles.ptrButtonHelp, 'enable', 'on');
		
	%release
	sGUI.handles.hDispHelp = hMsgBox;
	sGUI.IsBusy = false;
	guidata(sGUI.handles.hMain,sGUI);
end


