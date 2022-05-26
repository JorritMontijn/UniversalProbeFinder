function [strName,strMarker,vecColor] = SH_TrackUI(strDefName,varDefMarker,vecDefColor,strTitle)
	%get marker list
	cellMarkerList = {'+',...
		'o',...
		'*',...
		'.',...
		'x',...
		's',...
		'd',...
		'^',...
		'v',...
		'>',...
		'<',...
		'p',...
		'h'};
	
	%get default marker
	if ~exist('varDefMarker','var') || isempty(varDefMarker)
		varDefMarker = 1;
	end
	if ~ischar(varDefMarker)
		varDefMarker = mod(varDefMarker,numel(cellMarkerList));
		if varDefMarker == 0,varDefMarker=numel(cellMarkerList);end
		varDefMarker = cellMarkerList{varDefMarker};
	end
	intDefMarker = find(ismember(cellMarkerList,varDefMarker));
	if isempty(intDefMarker),intDefMarker=1;end
	
	%default title
	if ~exist('strTitle','var') || isempty(strTitle)
		strTitle = 'New track';
	end
	
	%default color
	if ~exist('vecDefColor','var') || isempty(vecDefColor)
		vecDefColor = 1;
	end
	if numel(vecDefColor) == 1
		matDefault=lines(7);
		matDefault(1,:)=[];
		intDefault = mod(vecDefColor,size(matDefault,1));
		if intDefault == 0,intDefault=size(matDefault,1);end
		vecDefColor = matDefault(intDefault,:);
	end
	
	%ask for name
	prompt = 'Name:';
	dims = [1 35];
	dlgtitle = strTitle;
	definput = {strDefName};
	cellOut = inputdlg(prompt,dlgtitle,dims,definput);
	if isempty(cellOut) || isempty(cellOut{1}),return;end
	strName = cellOut{1};
	
	%ask for marker
	[intSelected,boolAccept] = listdlg('Name',dlgtitle,'PromptString','Select a marker:',...
		'ListSize',[100 200],'SelectionMode','single','ListString',cellMarkerList,'InitialValue',intDefMarker);
	if ~boolAccept,return;end
	strMarker = cellMarkerList{intSelected};
	
	%ask color
	vecColor = selectcolor(vecDefColor);
	if isempty(vecColor),return;end
end
	