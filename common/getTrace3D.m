function matLines = getTrace3D(matEdge,intCurvesPerDim,dblMinSize)
	%getTrace3D Create mesh from 3D volume
	%   matLines = getTrace3D(matEdge,intCurvesPerDim,dblMinSize)
	
	if ~exist('dblMinSize','var') || isempty(dblMinSize)
		dblMinSize = numel(matEdge)/(3e4);
	end
	
	matLines = nan(0,3);
	% dim1
	vecPlotAt1 = unique(round(linspace(size(matEdge,1)/intCurvesPerDim,size(matEdge,1)-1/intCurvesPerDim*size(matEdge,1),intCurvesPerDim)));
	for intIdx1 = vecPlotAt1
		im1 = squeeze(matEdge(intIdx1,:,:));
		avCenter1 = imfill(im1,'holes');
		L = bwlabel(avCenter1);
		vecObjects = unique(L);
		for intObjIdx=1:(numel(vecObjects)-1)
			intObject = vecObjects(intObjIdx+1);
			imObj = L==intObject;
			[row,col] = find(imObj,1);
			B = bwtraceboundary(imObj,[row(1) col(1)],'W');
			if bwarea(imObj) < dblMinSize,continue;end
			vecI2 = B(:,1);
			vecI3 = B(:,2);
			matTempLines = cat(2,intIdx1*ones(size(vecI2)),vecI2,vecI3);
			matLines = cat(1,matLines,matTempLines,[nan nan nan]);
		end
	end
	
	%dim 2
	vecPlotAt2 = unique(round(linspace(size(matEdge,2)/intCurvesPerDim,size(matEdge,2)-1/intCurvesPerDim*size(matEdge,2),intCurvesPerDim)));
	for intIdx2 = vecPlotAt2
		im1 = squeeze(matEdge(:,intIdx2,:));
		avCenter1 = imfill(im1,'holes');
		L = bwlabel(avCenter1);
		vecObjects = unique(L);
		for intObjIdx=1:(numel(vecObjects)-1)
			intObject = vecObjects(intObjIdx+1);
			imObj = L==intObject;
			[row,col] = find(imObj,1);
			B = bwtraceboundary(imObj,[row(1) col(1)],'W');
			if bwarea(imObj) < dblMinSize,continue;end
			
			vecI2 = B(:,1);
			vecI3 = B(:,2);
			matTempLines = cat(2,vecI2,intIdx2*ones(size(vecI2)),vecI3);
			matLines = cat(1,matLines,matTempLines,[nan nan nan]);
		end
	end
	
	% dim3
	vecPlotAt3 = unique(round(linspace(size(matEdge,3)/intCurvesPerDim,size(matEdge,3)-1/intCurvesPerDim*size(matEdge,3),intCurvesPerDim)));
	for intIdx3 = vecPlotAt3
		im1 = squeeze(matEdge(:,:,intIdx3));
		avCenter1 = imfill(im1,'holes');
		L = bwlabel(avCenter1);
		vecObjects = unique(L);
		for intObjIdx=1:(numel(vecObjects)-1)
			intObject = vecObjects(intObjIdx+1);
			imObj = L==intObject;
			[row,col] = find(imObj,1);
			B = bwtraceboundary(imObj,[row(1) col(1)],'W');
			if bwarea(imObj) < dblMinSize,continue;end
			
			vecI2 = B(:,1);
			vecI3 = B(:,2);
			matTempLines = cat(2,vecI2,vecI3,intIdx3*ones(size(vecI2)));
			matLines = cat(1,matLines,matTempLines,[nan nan nan]);
		end
	end
end

