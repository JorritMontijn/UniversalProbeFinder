function sMeta = SH_UnpackCZI(strSlicePath,strFileName,dblReqResolution)
	%SH_UnpackCZI Unpacks CZI file
	%   sMeta = SH_UnpackCZI(strSlicePath,strFileName,dblReqResolution)
	%
	%To use, first install the bioformats toolbox:
	%download, extract, and add to path: https://downloads.openmicroscopy.org/bio-formats/7.1.0/artifacts/bfmatlab.zip
	
	%% assert bioformats
	intOutFlag = assertBioFormats();
	boolUseCzi = intOutFlag == 0;
	if ~exist('dblReqResolution','var') || isempty(dblReqResolution)
		dblReqResolution = 1000;
	end
	
	%% load
	strFileLoc = fullpath(strSlicePath,strFileName);
	if numel(strFileLoc) < 4 || ~strcmpi(strFileLoc((end-3):end),'.czi')
		strFileLoc((end+1):(end+4)) = '.czi';
	end
	sInfo  = cziinfo(strFileLoc);
	[strPath,strFile,strExt] = fileparts(strFileLoc);
	boolWriteTif = true;
	objReader = bfGetReader(strFileLoc);
	omeMeta = objReader.getMetadataStore();
	strXmlMeta=cast(omeMeta.dumpXML(),'char');
	sXml = xml2struct2(strXmlMeta);
	sMeta = sXml.OME;
	%xmlmeta = strrep(xmlmeta,'utf-8','UTF-8');
	%fID = fopen(strXmlFile,'w','n','UTF-8');
	%fwrite(fID,xmlmeta,'char');
	%fclose(fID);
	
	%go through scenes
	vecSceneList = [sInfo(:).scene];
	vecScaleList = [sInfo(:).scale];
	vecUniqueScenes = unique(vecSceneList);
	intSceneNum = numel(vecUniqueScenes);
	cellImages = cell(1,intSceneNum);
	for intSceneIdx = 1:intSceneNum
		%find best scale
		intScene = vecUniqueScenes(intSceneIdx);
		vecUseScenes = find(vecSceneList==intScene);
		vecScales = vecScaleList(vecUseScenes);
		vecX=[sInfo(vecUseScenes).sizex];
		vecY=[sInfo(vecUseScenes).sizey];
		[dummy,intUseScaleX] = min(abs(vecX-dblReqResolution));
		[dummy,intUseScaleY] = min(abs(vecY-dblReqResolution));
		intUseScale = vecScales(min(intUseScaleX,intUseScaleY));
		
		%find scene & scale
		intImage = find([sInfo(:).scene]==intScene & [sInfo(:).scale] == intUseScale,1);
		intChNum = sInfo(intImage).channelcount;
		for intCh=1:intChNum
			%  load image
			setSeries(objReader,intImage-1);
			imCh = imadjust(bfGetPlane(objReader, intCh));
			if intCh==1
				cellImages{intSceneIdx} = imCh;
			else
				cellImages{intSceneIdx}(:,:,intCh) = imCh;
			end
			
			%write tif?
			if boolWriteTif
				fprintf('Writing image %d/%d, channel %d/%d [%s]\n',intSceneIdx,intSceneNum,intCh,intChNum,getTime);
				strImOut = fullpath(strPath,[strFile '_S' num2str(intScene) '_C' num2str(intCh) '.tif']);
				imwrite(cellImages{intSceneIdx}(:,:,intCh),strImOut,'tiff');
			end
		end
	end
end
