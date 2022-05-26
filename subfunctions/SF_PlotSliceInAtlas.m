function SF_PlotSliceInAtlas(hMain,varargin)
	
	%get data
	sGUI = guidata(hMain);
	
	%get atlas
	sAtlas = sGUI.sAtlas;
	vecSizeMlApDv = size(sAtlas.av);
	
	%get slice
	sSlice = sGUI.sSliceData.Slice(sGUI.intCurrIm);
	imSlice = sSlice.ImTransformed;%y by x
	
	%get scale
	dblBaseScale = min(vecSizeMlApDv(1) / size(imSlice,2),vecSizeMlApDv(2) / size(imSlice,1));
	if isempty(sSlice.ResizeLeftRight),sSlice.ResizeLeftRight = dblBaseScale;end
	if isempty(sSlice.ResizeUpDown),sSlice.ResizeUpDown = dblBaseScale;end
	
	%get position
	if isempty(sSlice.Center),sSlice.Center = vecSizeMlApDv./2;end
	
	%get offset
	if isempty(sSlice.MidlineX),sSlice.MidlineX = size(imSlice,2)./2;end
	
	%get rotations
	if isempty(sSlice.RotateAroundAP),sSlice.RotateAroundAP = 0;end%roll
	if isempty(sSlice.RotateAroundML),sSlice.RotateAroundML = 0;end%pitch
	if isempty(sSlice.RotateAroundDV),sSlice.RotateAroundDV = 0;end%yaw
	
	%resize
	imResized = imresize(imSlice,[size(imSlice,1:2).*[sSlice.ResizeUpDown sSlice.ResizeLeftRight]]);
	%get center coordinates of image
	dblMiddleZ = size(imResized,1)./2;
	dblMiddleX = sSlice.MidlineX*sSlice.ResizeLeftRight;
	
	%get coordinates of pixels around center
	vecSizeSlice = size(imResized);
	[Z,X] = meshgrid(1:vecSizeSlice(1),1:vecSizeSlice(2)); %assume coronal orientation
	Y = zeros(size(X));
	X = dblMiddleX - X; %possibly subtracting way round
	Z = dblMiddleZ - Z; %size is X by Z (ML by DV if coronal)
	
	%get rotation
	%sSliceData.Slice(i).RotateAroundML = 1; %pitch: degrees up/down rotation in atlas space (relative to coronal)
	%sSliceData.Slice(i).RotateAroundDV = 2; %yaw: degrees left/right rotation in atlas space (relative to coronal)
	%sSliceData.Slice(i).RotateAroundAP = 3; %roll: degrees counterclockwise rotation in atlas space (same as VecMidline) (relative to coronal)
	
	%move slice to atlas space
	X = round(X + sSlice.Center(1)); %ML
	Y = round(Y + sSlice.Center(2)); %AP
	Z = round(Z + sSlice.Center(3)); %DV
	
	
	% Update the slice display
	imCh1 = imResized(:,:,1);
	imCh2 = imResized(:,:,2);
	imCh3 = imResized(:,:,3);
	CData = cat(3,imCh1',imCh2',imCh3');
	set(sGUI.handles.hSliceInAtlas,'XData',X,'YData',Y,'ZData',Z,'CData',CData);
	
	%remove entries outside atlas
	X(X<1 | X>vecSizeMlApDv(1)) = 1;
	Y(Y<1 | Y>vecSizeMlApDv(2)) = 1;
	Z(Z<1 | Z>vecSizeMlApDv(3)) = 1;
	
	%retrieve atlas areas in slice
	vecGetIdx = sub2ind(vecSizeMlApDv,X,Y,Z);
	A = sGUI.sAtlas.av(vecGetIdx);
	
	%overlay atlas on slice
	[Yoverlay,Xoverlay] = meshgrid(size(A,2):-1:1,1:size(A,1));
	set(sGUI.handles.hAtlasInSlice,'XData',Xoverlay,'YData',Yoverlay,'ZData',ones(size(Xoverlay)),'CData',A);
	
	%update slice to gui
	sGUI.sSliceData.Slice(sGUI.intCurrIm) = sSlice;
	guidata(hMain,sGUI);
	
end