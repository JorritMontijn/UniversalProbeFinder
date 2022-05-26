function [hHeader,sHeaderHandles] = SH_GenSliceHeader(hMain,sSliceData)
	
	
	hHeader = uipanel(hMain,'BackgroundColor','white','Position',[0 0.8 1 0.2]);
	intCurrSlice = 1;
	vecShowSlices = (intCurrSlice-3):(intCurrSlice+3);
	vecPlotPos=1:numel(vecShowSlices);
	intBigPos = find(vecShowSlices==intCurrSlice);
	vecPlotAx = nan(size(vecPlotPos));
	vecPlotX = linspace(0.05,0.95,numel(vecShowSlices)+2);
	vecPlotX(intBigPos+1) = []; %remove bigpos+1 as this will be taken by big pos
	vecWidth = diff(vecPlotX)-0.01;
	vecPlotX(end) = []; %remove end
	for intMakePlot=vecPlotPos
		%create axes
		boolIsBig = intMakePlot==intBigPos;
		vecPlotAx(intMakePlot) = axes(hHeader,'Position',[vecPlotX(intMakePlot) 0.5*double(~boolIsBig) vecWidth(intMakePlot) 0.5+0.5*double(boolIsBig)]);
		axis(vecPlotAx(intMakePlot),'off')
		
		%plot initial images
		intPlotSlice = vecShowSlices(intMakePlot);
		if intPlotSlice < 1 || intPlotSlice > numel(sSliceData.Slice)
			cla(vecPlotAx(intMakePlot));
		else
			imPlot = sSliceData.Slice(intPlotSlice).ImTransformed;
			imshow(imPlot,'Parent',vecPlotAx(intMakePlot));
		end
	end
	
	%add to struct
	sHeaderHandles = struct;
	sHeaderHandles.hHeader = hHeader;
	sHeaderHandles.vecPlotAx = vecPlotAx;
end