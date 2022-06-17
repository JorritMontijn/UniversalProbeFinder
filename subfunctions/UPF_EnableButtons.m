function UPF_EnableButtons(sUPF_ChooseGui)
	sUPF_ChooseGui.handles.ptrButtonPrepper.Enable = 'on';
	sUPF_ChooseGui.handles.ptrButtonFinder.Enable = 'on';
	sUPF_ChooseGui.handles.ptrButtonProber.Enable = 'on';
	sUPF_ChooseGui.handles.ptrButtonSetter.Enable = 'on';
	drawnow;
end