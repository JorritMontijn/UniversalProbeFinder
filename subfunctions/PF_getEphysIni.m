function sEphysParams = PF_getEphysIni()
	%PF_getEphysIni Reads Ephys parameters from ini file
	%   sEphysParams = PF_getEphysIni()
	
	%check for ini file
	strPathFile = mfilename('fullpath');
	cellDirs = strsplit(strPathFile,filesep);
	strPath = strjoin(cellDirs(1:(end-2)),filesep);
	strIni = strcat(strPath,filesep,'configEphys.ini');
	
	%load ini
	if exist(strIni,'file')
		%load data
		fFile = fopen(strIni,'rt');
		vecData = fread(fFile);
		fclose(fFile);
		%convert
		strData = cast(vecData','char');
		[cellStructs,cellStructNames] = ini2struct(strData);
		for intIdx=1:numel(cellStructs)
			eval([cellStructNames{intIdx} '= cellStructs{' num2str(intIdx) '};']);
		end
	else
		% default data; generate if no ini exists
		sEphysParams = struct;
		%kilosort
		sEphysParams(1).name = 'Kilosort';
		sEphysParams(1).loader = 'EL_PrepEphys_KS';
		sEphysParams(1).reqfiles = 'params.py,spike_times.npy,spike_templates.npy,spike_clusters.npy,amplitudes.npy,cluster_ContamPct.tsv,cluster_KSlabel.tsv';
		sEphysParams(1).reqisregexp = 0;
		%spikeglx
		sEphysParams(2).name = 'SpikeGLX';
		sEphysParams(2).loader = 'EL_PrepEphys_SG';
		sEphysParams(2).reqfiles = '.*[.]imec.*[.]ap[.]bin,.*[.]imec.*[.]ap[.]meta,.*[.]nidq[.]bin,.*[.]nidq[.]meta';
		sEphysParams(2).reqisregexp = 1;
		%Acquipix synthesis
		sEphysParams(3).name = 'Acquipix Synthesis';
		sEphysParams(3).loader = 'EL_PrepEphys_AS';
		sEphysParams(3).reqfiles = '.*Synthesis[.]mat';
		sEphysParams(3).reqisregexp = 1;
		
		%write ini
		strData=struct2ini(sEphysParams,'sEphysParams');
		fFile = fopen(strIni,'wt');
		fprintf(fFile,strData);
		fclose(fFile);
	end
	
	%parse cell structs
	for intEphysType=1:numel(sEphysParams)
		sEphysParams(intEphysType).reqfiles = strsplit(sEphysParams(intEphysType).reqfiles,',');
	end
end
