function SH_DisplaySlicePrepperControls(varargin)
	
	% Print controls
	CreateStruct.Interpreter = 'tex';
	CreateStruct.WindowStyle = 'non-modal';
	msgbox( ...
		{'\fontsize{12}Tip: if the keyboard controls stop working after you press a button, click somewhere in the header area to return focus to the GUI.' ...
		'' ...
		'\bf Image navigation: \rm' ...
		'Left/right arrow  : move to previous/next image' ...
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
		'F1      : bring up this window'}, ...
		'Controls',CreateStruct);
	
	
	%reset focus
	if nargin > 0
		sGUI = guidata(varargin{1});
		figure(sGUI.handles.hMain);
		set(sGUI.handles.ptrButtonHelp, 'enable', 'off');
		drawnow;
		set(sGUI.handles.ptrButtonHelp, 'enable', 'on');
	end
end

