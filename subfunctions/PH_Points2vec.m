function [vecSphereVector,vecLocBrainIntersect,matRefVector] = PH_Points2vec(sProbeCoords,sAtlas)
	
	%pre-allocate dummies
	vecSphereVector = [];
	vecLocBrainIntersect = [];
	matRefVector = [];
	
	%get probe length
	if isfield(sProbeCoords,'ProbeLength') && ~isempty(sProbeCoords.ProbeLength)
		dblProbeLength = sProbeCoords.ProbeLength;
	else
		dblProbeLength = 1000;
	end
	%assume the probe is pointed downward
	matHistoPoints = sProbeCoords.cellPoints{sProbeCoords.intProbeIdx};
	if size(matHistoPoints,2)>3,matHistoPoints=matHistoPoints';end
	[dummy,vecReorder]=sort(matHistoPoints(:,3),'descend');
	matHistoPoints = matHistoPoints(vecReorder,:);
	
	%get probe vector from points
	matRefVector = PH_GetRefVector(matHistoPoints);
	
	%get intersection
	vecLocBrainIntersect = PH_GetBrainIntersection(matRefVector,sAtlas.av);
	if isempty(vecLocBrainIntersect)
		vecProbeLoc = matRefVector(1,:);
	else
		vecProbeLoc = vecLocBrainIntersect(1:3);
	end
	
	%get angles
	vecD = diff(matRefVector);
	vecNormD = vecD./norm(vecD);
	vecSphereVector1 = PH_CartVec2SphVec(matRefVector);
	
	%extract angles in degrees
	dblAngleML = vecSphereVector1(4);
	dblAngleAP = vecSphereVector1(5);
	
	%set correct probe tip & length
	vecSphereVector = [vecProbeLoc(:)'-(vecNormD*dblProbeLength) dblAngleML dblAngleAP dblProbeLength];
end
	