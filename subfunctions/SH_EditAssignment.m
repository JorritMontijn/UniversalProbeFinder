function strNewAssignment = SH_EditAssignment(strTitle,strAssignment)
	%SH_EditAssignment Small GUI to edit assignment
	%   strNewAssignment = SH_EditAssignment(strTitle,strAssignment)
	
	%open edit figure
	%create GUI: OK, delete, move up, move down
	hEditGui = figure('Name','Edit Assignment','WindowStyle','Normal','Menubar','none','NumberTitle','off','Position',[500 300 300 200]);
	hEditGui.Units = 'normalized';
	
	%split assignment
	strF = getFlankedBy(strAssignment,'F','S');
	intFieldSize = numel(strF);
	intF = str2double(strF);
	intS = str2double(getFlankedBy(strAssignment,'S','X'));
	intX = str2double(getFlankedBy(strAssignment,'X','Y'));
	intY = str2double(getFlankedBy(strAssignment,'Y','Z'));
	intZ = str2double(getFlankedBy(strAssignment,'Z','C'));
	intC = str2double(getFlankedBy(strAssignment,'C','E'));
	vecAssignment = [intF intS intX intY intZ intC];
	
	% / "Title"
	%F / File #:
	%S / Image #:
	%C / Channel:
	% / Tiling
	%X / X:
	%Y / Y:
	%Z / Z:
	% / Accept Cancel
	
	%create buttons
	handleEdit = struct;
	handleEdit.hMain = hEditGui;
	
	handleEdit.ptrTextTitle = uitext(hEditGui,'Style','text','String',strTitle,...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',12,'Position',[0.01 0.9 0.98 0.1],'Interpreter','none');
	
	dblStartX = 0.2;
	%F
	handleEdit.ptrTextF = uitext(hEditGui,'Style','text','String','File #',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',[dblStartX 0.8 0.2 0.1]);
	handleEdit.ptrEditF = uicontrol(hEditGui,'Style','edit','String',num2str(intF),...
		'Units','normalized','FontSize',10,'Position',[0.5 0.8 0.2 0.1],...
		'Tag','F','Callback',@UIE_Edit);
	%S
	handleEdit.ptrTextS = uitext(hEditGui,'Style','text','String','Image #',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',[dblStartX 0.7 0.2 0.1]);
	handleEdit.ptrEditS = uicontrol(hEditGui,'Style','edit','String',num2str(intS),...
		'Units','normalized','FontSize',10,'Position',[0.5 0.7 0.2 0.1],...
		'Tag','S','Callback',@UIE_Edit);
	%C
	handleEdit.ptrTextC = uitext(hEditGui,'Style','text','String','Channel #',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',[dblStartX 0.6 0.2 0.1]);
	handleEdit.ptrEditC = uicontrol(hEditGui,'Style','edit','String',num2str(intC),...
		'Units','normalized','FontSize',10,'Position',[0.5 0.6 0.2 0.1],...
		'Tag','C','Callback',@UIE_Edit);
	
	
	%tiling
	handleEdit.ptrTextTiling = uitext(hEditGui,'Style','text','String','Tiling:',...
		'VerticalAlignment','middle','Units','normalized','FontSize',12,'Position',[0.3 0.5 0.4 0.1]);
	
	%X
	handleEdit.ptrTextX = uitext(hEditGui,'Style','text','String','X location',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',[dblStartX 0.4 0.2 0.1]);
	handleEdit.ptrEditX = uicontrol(hEditGui,'Style','edit','String',num2str(intX),...
		'Units','normalized','FontSize',10,'Position',[0.5 0.4 0.2 0.1],...
		'Tag','X','Callback',@UIE_Edit);
	
	%Y
	handleEdit.ptrTextY = uitext(hEditGui,'Style','text','String','Y location',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',[dblStartX 0.3 0.2 0.1]);
	handleEdit.ptrEditY = uicontrol(hEditGui,'Style','edit','String',num2str(intY),...
		'Units','normalized','FontSize',10,'Position',[0.5 0.3 0.2 0.1],...
		'Tag','Y','Callback',@UIE_Edit);
	
	%Z
	handleEdit.ptrTextZ = uitext(hEditGui,'Style','text','String','Z location',...
		'HorizontalAlignment','left','VerticalAlignment','middle','Units','normalized','FontSize',10,'Position',[dblStartX 0.2 0.2 0.1]);
	handleEdit.ptrEditZ = uicontrol(hEditGui,'Style','edit','String',num2str(intZ),...
		'Units','normalized','FontSize',10,'Position',[0.5 0.2 0.2 0.1],...
		'Tag','Z','Callback',@UIE_Edit);
	
	
	%accept
	handleEdit.ptrButtonAccept = uicontrol(hEditGui,'Style','pushbutton','String','Accept',...
		'HorizontalAlignment','center','Units','normalized','FontSize',12,'Position',[0.25 0.01 0.5 0.15],...
		'Callback',@UIE_Accept);
	
	%set guidata
	sUEG = struct;
	sUEG.hMain = hEditGui;
	sUEG.strTitle = strTitle;
	sUEG.strAssignment = strAssignment;
	sUEG.vecAssignment = vecAssignment;
	sUEG.strAssignment = strAssignment;
	sUEG.handles=handleEdit;
	guidata(hEditGui,sUEG);
		
	%move
	movegui(hEditGui,'center');
	
	%wait for accept (or cancel)
	uiwait(hEditGui);
	
	if ishandle(hEditGui) && strcmp(hEditGui.UserData,'Accept')
		%retrieve new assignment
		strFieldSize = ['%0' num2str(intFieldSize) 'd'];
		strFormat = ['F' strFieldSize 'S' strFieldSize 'X' strFieldSize 'Y' strFieldSize 'Z' strFieldSize 'C' strFieldSize 'E'];
		strNewAssignment = sprintf(strFormat,...
			str2double(handleEdit.ptrEditF.String),...
			str2double(handleEdit.ptrEditS.String),...
			str2double(handleEdit.ptrEditX.String),...
			str2double(handleEdit.ptrEditY.String),...
			str2double(handleEdit.ptrEditZ.String),...
			str2double(handleEdit.ptrEditC.String));
		
		%close
		close(hEditGui);
	else
		%do nothing
		strNewAssignment = strAssignment;
	end
end
function UIE_Edit(hObject,eventdata)

	%check if data is numeric
	sUEG = guidata(hObject);
	strKey = 'FSXYZC';
	vecAssignment = sUEG.vecAssignment;
	intEntry = find(ismember(strKey,hObject.Tag));
	dblConv = str2double(hObject.String);
	if isempty(dblConv) || isnan(dblConv) || (strcmp(hObject.Tag,'C') && (dblConv<0 || dblConv > 3))
		hObject.String = num2str(vecAssignment(intEntry));
	else
		hObject.String = num2str(round(dblConv));
	end
end
function UIE_Accept(hMain,eventdata)
	%get data
	handles = guidata(hMain);
	handles.hMain.UserData = 'Accept';
	uiresume(handles.hMain);
end