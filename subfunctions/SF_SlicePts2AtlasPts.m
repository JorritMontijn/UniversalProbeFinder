function [Xa,Ya,Za] = SF_SlicePts2AtlasPts(Xs,Ys,sSlice,vecSizeMlApDv)
	%SF_SlicePts2AtlasPts Transform slice coordinates to atlas coordinates
	%[Xa,Ya,Za] = SF_SlicePts2AtlasPts(Xs,Ys,sSlice,vecSizeMlApDv)
	%
	%Input: 
	%Xs: column vector of horizontal (ML) slice coordinates
	%Ys: column vector of vertical (DV) slice coordinates
	%sSlice: slice structure
	%vecSizeMlApDv: atlas size (only required if slice values are empty)
	%
	%Ouput:
	%Xa: column vector of ML coordinates
	%Ya: column vector of AP coordinates
	%Za: column vector of DV coordinates
	%
	%Note that Z in atlas space is Y in slice space. This means that if all transformations are 0,
	%then Za=Ys and Ya=zeros(size(Xa)) as Y in atlas space is AP, while Y in slice space is DV.
	
	
	%check input
	if size(Xs,2) > 1 || size(Ys,2) > 1
		error([mfilename ':FormatError'],'Input coordinates must be column vectors');
	end
	
	%assign defaults if empty
	if ~exist('vecSizeMlApDv','var') || isempty(vecSizeMlApDv),vecSizeMlApDv = [1140 1320 800];end
	
	%get slice
	imSlice = sSlice.ImTransformed;%y by x
	
	%get scale
	dblBaseScale = min(vecSizeMlApDv(1) / size(imSlice,2),vecSizeMlApDv(2) / size(imSlice,1));
	if isempty(sSlice.ResizeLeftRight),sSlice.ResizeLeftRight = dblBaseScale;end
	if isempty(sSlice.ResizeUpDown),sSlice.ResizeUpDown = dblBaseScale;end
	
	%get position
	if isempty(sSlice.Center),sSlice.Center = vecSizeMlApDv./2;end
	
	%get offset
	if isempty(sSlice.MidlineX) || sSlice.MidlineX == 0,sSlice.MidlineX = size(imSlice,2)./2;end
	
	%get rotations
	if isempty(sSlice.RotateAroundAP),sSlice.RotateAroundAP = 0;end%roll
	if isempty(sSlice.RotateAroundML),sSlice.RotateAroundML = 0;end%pitch
	if isempty(sSlice.RotateAroundDV),sSlice.RotateAroundDV = 0;end%yaw
	
	%resize
	Xa = Xs*sSlice.ResizeLeftRight;
	Za = Ys*sSlice.ResizeUpDown;
	vecNewSize = round(size(sSlice.ImTransformed,1:2).*[sSlice.ResizeUpDown sSlice.ResizeLeftRight]);
	
	%get center coordinates of image
	dblMiddleZ = vecNewSize(1)./2;
	dblMiddleX = sSlice.MidlineX*sSlice.ResizeLeftRight;
	
	%get coordinates of pixels around center
	Ya = zeros(size(Xa));
	Xa = dblMiddleX - Xa;
	Za = dblMiddleZ - Za;
	
	%get rotation
	dblYawDV = sSlice.RotateAroundDV; %yaw: degrees left/right rotation in atlas space (relative to coronal)
	dblPitchML = sSlice.RotateAroundML; %pitch: degrees up/down rotation in atlas space (relative to coronal)
	dblRollAP = sSlice.RotateAroundAP; %roll: degrees counterclockwise rotation in atlas space (same as VecMidline) (relative to coronal)
	
	% build rotation matrix in yaw pitch roll
	a = deg2rad(dblYawDV);
	c = deg2rad(dblPitchML);
	b = deg2rad(dblRollAP);
	matR = [...
		cos(a)*cos(b)	cos(a)*sin(b)*sin(c)-sin(a)*cos(c)	cos(a)*sin(b)*cos(c)+sin(a)*sin(c);...
		sin(a)*cos(b)	sin(a)*sin(b)*sin(c)+cos(a)*cos(c)	sin(a)*sin(b)*cos(c)-cos(a)*sin(c);...
		-sin(b)			cos(b)*sin(c)						cos(b)*cos(c)]';
	
	%transform to points, rotate, and transform back
	matP = cat(2,Xa,Ya,Za)';
	matRotP = matR*matP;
	
	%add center
	Xa = matRotP(1,:)' + sSlice.Center(1);
	Ya = matRotP(2,:)' + sSlice.Center(2);
	Za = matRotP(3,:)' + sSlice.Center(3);
end