function [cellHeader,cellData] = tsvread(strFile)
	%tsvread Reads tsv files
	%   [cellHeader,cellData] = tsvread(strFile)
	
	%read all lines
	fid = fopen( strFile, 'r' );
	cellLines = textscan( fid, '%s', 'delimiter', '\n');
	cellLines = cellLines{1};
	fclose(fid);
	intLineNum = size(cellLines,1);
	 
	%get header
	cellSplit = strsplit(cellLines{1}, '\t');
	indRem = isempty(cellSplit);
	cellSplit(indRem)=[];
	cellHeader = cellSplit;
	intColumnNum = numel(cellHeader);
	
	%read data
	cellData = cell(intLineNum-1,intColumnNum);
	for i=2:intLineNum
		cellSplitData = strsplit(cellLines{i}, '\t');
		cellSplitData(indRem) = [];
		cellData(i-1,:) = cellSplitData;
	end
end