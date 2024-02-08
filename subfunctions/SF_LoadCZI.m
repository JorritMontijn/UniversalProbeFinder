%function [outputArg1,outputArg2] = SF_LoadCZI(strFile)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%download, extract, and add to path: https://downloads.openmicroscopy.org/bio-formats/7.1.0/artifacts/bfmatlab.zip

strFile = 'H:\DataNeuropixels\TissueScans\BL6\Topo7\Valentina_160320220319.czi';
sInfo  = czifinfo(strFile);

%load with bfopen
data = bfopen(strFile);

%% load
reader = bfGetReader(strFile);
omeMeta = reader.getMetadataStore();
series1_plane1 = bfGetPlane(reader, 1);
xmlmeta=cast(omeMeta.dumpXML(),'char');
strXmlFile = 'H:\DataNeuropixels\TissueScans\BL6\Topo7\Valentina_160320220319.xml';
fID = fopen(strXmlFile,'w','n','UTF-8');
fwrite(fID,xmlmeta);
fclose(fID);
sInfo  = czifinfo(strFile);

sMeta=xmlread(strXmlFile)
%%
%go through blocks
fID = fopen(strFile);

%detect source bit
%sInfo.genInfo.pixelType
try
	%get general info
	vecStartX = cell2vec({sInfo.sBlockList_P0.XStart});
	vecSizeX = cell2vec({sInfo.sBlockList_P0.XSize});
	vecStartY = cell2vec({sInfo.sBlockList_P0.YStart});
	vecSizeY = cell2vec({sInfo.sBlockList_P0.YSize});
	vecStartC = cell2vec({sInfo.sBlockList_P0.CStart});
	vecStartM = cell2vec({sInfo.sBlockList_P0.MStart});
	
	intMinX = min(vecStartX);
	intMaxX = max(vecStartX+vecSizeX);
	intRangeX = intMaxX - intMinX + 1;
	
	intMinY = min(vecStartY);
	intMaxY = max(vecStartY+vecSizeY);
	intRangeY = intMaxY - intMinY + 1;
	
	intMinC = min(vecStartC);
	intMaxC = max(vecStartC);
	intRangeC = intMaxC - intMinC  + 1;
	
	intMinM = min(vecStartM);
	intMaxM = max(vecStartM);
	intRangeM = intMaxM - intMinM + 1;
	
	%pre-allocate
	matOut = zeros(intRangeX,intRangeY,intRangeC,'uint8');
	
	%load data
	for i=1:numel(sInfo.sBlockList_P0)
		%get block start
		intStart = sInfo.sBlockList_P0(i).dataStartPos;
		
		%get current location and skip to block start
		intCurrPos = ftell(fID);
		fseek(fID,intStart-intCurrPos,'cof');
		
		%read data
		intSize = sInfo.sBlockList_P0(i).dataSize;
		blockData = fread(fID,intSize);%'uint16=>uint8'
		
		%assign data
		intBeginX = sInfo.sBlockList_P0(i).XStart;
		intSizeX = sInfo.sBlockList_P0(i).XSize;
		vecAssignX = ((intBeginX - intMinX):(intBeginX + intSizeX - intMinX)) + 1;
		
		intBeginY = sInfo.sBlockList_P0(i).YStart;
		intSizeY = sInfo.sBlockList_P0(i).YSize;
		vecAssignY = ((intBeginY - intMinY):(intBeginY + intSizeY - intMinY)) + 1;
		
		intEls = intSizeX*intSizeY;
		
		matOut(intBeginX:(intBeginX)
		
	end
	fclose(fID);
catch
	fclose(fID);
end
%end

