function sRegExpAssignment = SH_MagicAssignment()
	%SH_MagicAssignment Edit regexps
	%   sRegExpAssignment = SH_MagicAssignment()
	
	%open edit figure
	%create GUI: OK, delete, move up, move down
	hMagicGui = figure('Name','Edit Regexps','WindowStyle','Normal','Menubar','none','NumberTitle','off','Position',[500 300 300 200]);
	hMagicGui.Units = 'normalized';
	
	%default
	sRegExpAssignment = struct;
	sRegExpAssignment.File = '\w*_S';
	sRegExpAssignment.Image = 'S\d*';
	sRegExpAssignment.Ch1 = 'C0*1';
	sRegExpAssignment.Ch2 = 'C0*2';
	sRegExpAssignment.Ch3 = 'C0*3';
	sRegExpAssignment.X = 'X\d*';
	sRegExpAssignment.Y = 'Y\d*';
	sRegExpAssignment.Z = 'Z\d*';
	
	%File:
	%Image:
	%Ch1:
	%Ch2:
	%Ch3:
	%X:
	%Y:
	%Z:
	%Accept
	
	%create buttons
	handleMagic = struct;
	handleMagic.hMain = hMagicGui;
	
	dblStartX = 0.2;
	%F
	handleMagic.ptrTextF = uitext(hMagicGui,'Style','text','String','File:',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',...
		[dblStartX 0.9 0.2 0.1]);
	handleMagic.ptrEditF = uicontrol(hMagicGui,'Style','edit','String',sRegExpAssignment.File,...
		'Units','normalized','FontSize',10,'Position',[0.5 0.9 0.2 0.1],...
		'Tag','F');
	%S
	handleMagic.ptrTextS = uitext(hMagicGui,'Style','text','String','Image:',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',...
		[dblStartX 0.8 0.2 0.1]);
	handleMagic.ptrEditS = uicontrol(hMagicGui,'Style','edit','String',sRegExpAssignment.Image,...
		'Units','normalized','FontSize',10,'Position',[0.5 0.8 0.2 0.1],...
		'Tag','S');
	%C1
	handleMagic.ptrTextC1 = uitext(hMagicGui,'Style','text','String','Channel 1:',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',...
		[dblStartX 0.7 0.2 0.1]);
	handleMagic.ptrEditC1 = uicontrol(hMagicGui,'Style','edit','String',sRegExpAssignment.Ch1,...
		'Units','normalized','FontSize',10,'Position',[0.5 0.7 0.2 0.1],...
		'Tag','C1');
	%C2
	handleMagic.ptrTextC2 = uitext(hMagicGui,'Style','text','String','Channel 2:',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,...
		'Position',[dblStartX 0.6 0.2 0.1]);
	handleMagic.ptrEditC2 = uicontrol(hMagicGui,'Style','edit','String',sRegExpAssignment.Ch2,...
		'Units','normalized','FontSize',10,'Position',[0.5 0.6 0.2 0.1],...
		'Tag','C2');
	%C3
	handleMagic.ptrTextC3 = uitext(hMagicGui,'Style','text','String','Channel 3:',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,...
		'Position',[dblStartX 0.5 0.2 0.1]);
	handleMagic.ptrEditC3 = uicontrol(hMagicGui,'Style','edit','String',sRegExpAssignment.Ch3,...
		'Units','normalized','FontSize',10,'Position',[0.5 0.5 0.2 0.1],...
		'Tag','C3');
	
	%X
	handleMagic.ptrTextX = uitext(hMagicGui,'Style','text','String','X location:',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,...
		'Position',[dblStartX 0.4 0.2 0.1]);
	handleMagic.ptrEditX = uicontrol(hMagicGui,'Style','edit','String',sRegExpAssignment.X,...
		'Units','normalized','FontSize',10,'Position',[0.5 0.4 0.2 0.1],...
		'Tag','X');
	
	%Y
	handleMagic.ptrTextY = uitext(hMagicGui,'Style','text','String','Y location:',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,...
		'Position',[dblStartX 0.3 0.2 0.1]);
	handleMagic.ptrEditY = uicontrol(hMagicGui,'Style','edit','String',sRegExpAssignment.Y,...
		'Units','normalized','FontSize',10,'Position',[0.5 0.3 0.2 0.1],...
		'Tag','Y');
	
	%Z
	handleMagic.ptrTextZ = uitext(hMagicGui,'Style','text','String','Z location:',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,...
		'Position',[dblStartX 0.2 0.2 0.1]);
	handleMagic.ptrEditZ = uicontrol(hMagicGui,'Style','edit','String',sRegExpAssignment.Z,...
		'Units','normalized','FontSize',10,'Position',[0.5 0.2 0.2 0.1],...
		'Tag','Z');
	
	
	%accept
	handleMagic.ptrButtonAccept = uicontrol(hMagicGui,'Style','pushbutton','String','Assign',...
		'HorizontalAlignment','center','Units','normalized','FontSize',12,'Position',[0.25 0.01 0.5 0.15],...
		'Callback',@UIE_Accept);
	
	%set guidata
	sUIE = struct;
	sUIE.hMain = hMagicGui;
	sUIE.handles=handleMagic;
	guidata(hMagicGui,sUIE);
		
	%move
	movegui(hMagicGui,'center');
	
	%wait for accept (or cancel)
	uiwait(hMagicGui);
	
	if ishandle(hMagicGui) && strcmp(hMagicGui.UserData,'Accept')
		%retrieve new assignment
		sRegExpAssignment.File = handleMagic.ptrEditF.String;
		sRegExpAssignment.Image = handleMagic.ptrEditS.String;
		sRegExpAssignment.Ch1 = handleMagic.ptrEditC1.String;
		sRegExpAssignment.Ch2 = handleMagic.ptrEditC2.String;
		sRegExpAssignment.Ch3 = handleMagic.ptrEditC3.String;
		sRegExpAssignment.X = handleMagic.ptrEditX.String;
		sRegExpAssignment.Y = handleMagic.ptrEditY.String;
		sRegExpAssignment.Z = handleMagic.ptrEditZ.String;
	
		%close
		close(hMagicGui);
	else
		%do nothing
		sRegExpAssignment = [];
	end
end
function UIE_Accept(hMain,eventdata)
	%get data
	handles = guidata(hMain);
	handles.hMain.UserData = 'Accept';
	uiresume(handles.hMain);
end