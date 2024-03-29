function PH_DisplayControls(hObject,boolEnableButtons,varargin)
	
	%check if help is already open
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	if ~isempty(sGUI.handles.hDispHelp) && ishandle(sGUI.handles.hDispHelp)
		figure(sGUI.handles.hDispHelp);return;
	end
	if ~exist('boolEnableButtons','var') || isempty(boolEnableButtons) || ~islogical(boolEnableButtons)
		boolEnableButtons = true;
	end
	
	%enable buttons
	if boolEnableButtons
		PH_EnableButtons(hObject);
	end
	
	% Print controls
	CreateStruct.Interpreter = 'tex';
	CreateStruct.WindowStyle = 'non-modal';
	cellTxt = {''...
		'\fontsize{12}' ...
		'\bfTip: If the GUI is slow, try turning off the atlas slice (s)\rm' ...
		'' ...
		'\bf Probe: \rm' ...
		'Arrow keys : translate probe' ...
		'Alt/Option up/down : raise/lower probe' ...
		'Alt/Option left/right : shrink/stretch probe' ...
		'Shift arrow keys : change probe angle' ...
		'Shift +/- : change step size' ...
		'm : set probe location manually', ...
		''...
		'\bf 3D brain areas: \rm' ...
		' =/+ : add (list selector)' ...
		' Alt/Option =/+ : add (search)' ...
		' - : remove', ...
		''...
		'\bf Visibility: \rm' ...
		's : atlas slice (toggle tv/av/off)' ...
		't : slice transparency (toggle on/off)' ...
		'b : brain outline' ...
		'p : probe' ...
		'd : histology points' ...
		'o : origin location' ...
		'a : 3D brain areas' ...
		''...
		'\bf Other: \rm' ...
		'x : export probe coordinates to workspace' ...
		'h : load and plot histology-defined trajectory', ...
		'F1 : bring up this window'};
	hMsgBox = msgbox( ...
		cellTxt, ...
		'Controls',CreateStruct);
	
	%add link to manual
	vecPos = [0 (1 - 1/numel(cellTxt)) 1 1/numel(cellTxt)];
	hAx = axes(hMsgBox,'Position',vecPos);
	axis(hAx,'off');
	hTxt = text(hAx,0.9,0.5,'$\mathrm{\underline{Manual}}$',...
		'color',[0 0 .8],'FontSize',12,'Interpreter','latex',...
		'HorizontalAlignment','right');
	hTxt.ButtonDownFcn = @(~,~)web('https://github.com/JorritMontijn/UniversalProbeFinder/blob/main/UserGuide_UniversalProbeFinder_v1.1.pdf'); % this opens the website

	%add handles & return to hMsgBox
	hRealMain = sGUI.handles.hMain;
	sMiniGUI = struct;
	sMiniGUI.hMain = hRealMain;
	sMiniGUI.handles = sGUI.handles;
	guidata(hMsgBox,sMiniGUI);
	set(hMsgBox,'KeyPressFcn',@PH_KeyPress);
	set(hMsgBox,'DeleteFcn',@PH_DeleteHelpFcn);
	
	%update main gui
	sGUI.handles.hDispHelp = hMsgBox;
	guidata(sGUI.handles.hMain,sGUI);
end


