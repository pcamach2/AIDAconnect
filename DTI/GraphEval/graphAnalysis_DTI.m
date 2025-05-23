function [graphCell,matrixValues,ids]=graphAnalysis_DTI(inputDTI)

%% graphAnalysis
% This function is used by mergeDTIdata_input.m and is not meant to be
% used manually.

path = inputDTI.out_path;
groups = inputDTI.groups;
days = inputDTI.days;
%% Load related information
tempFile = load('../Tools/infoData/acronyms_splitted.mat');
acronyms = tempFile.acronyms;
tempFile = load('../Tools/infoData/acro_numbers_splitted.mat');
acro_numbers = tempFile.annotationsNumber;
niiData = load_nii('../Tools/infoData/annoVolume+2000_rsfMRI.nii.gz');
volume = niiData.img;
%% Find center of gravity for existing labels
x_coord = nan(length(acro_numbers),1);
y_coord = nan(length(acro_numbers),1);
z_coord = nan(length(acro_numbers),1);
for i = 1:length(acro_numbers)
[r,c,v] = ind2sub(size(volume),find(volume == acro_numbers(i)));
x_coord(i) = ceil(mean(r));
y_coord(i) = ceil(mean(c));
z_coord(i) = ceil(mean(v));
end

%% Create graphs
matrixValues = cell(length(groups),length(days));
ids = cell(length(groups),length(days));
graphCell = cell(length(groups),length(days));
for gIdx = 1:length(groups)
    disp('Load '+groups(gIdx))
    for dIdx = 1:length(days)
        
        % Load the files created by getMergedDTI_data.m 
        % and get the fiber count matrices     
        tempFile = load(fullfile(path,groups(gIdx),[(days(dIdx)) + '.mat']));
        tempMatrices = tempFile.infoDTI.matrix;
        meanMatrixValues = mean(tempMatrices,3);
        ids{gIdx,dIdx} = tempFile.infoDTI.names;
        
        disp(days(dIdx))
        
        % Build the graph using the upper triangle of the matrix stored
        % in meanMatrixValues
        G = graph(meanMatrixValues, cellstr(acronyms),'upper');
        G.Nodes.XCoord = x_coord;
        G.Nodes.YCoord = y_coord;
        G.Nodes.ZCoord = z_coord;
        
        % Store the matrices of all individual subjects in allMatrix 
        G.Nodes.allMatrix = tempMatrices;
       
        % Store local graph metrics at each node (region)
        for mIdx = 1:size(G.Nodes.allMatrix,3) % mIdx = animal Index
            G.Nodes.allDegree(:,mIdx) = tempFile.infoDTI.degrees(mIdx,:);
            G.Nodes.allStrength(:,mIdx) = tempFile.infoDTI.strengths(mIdx,:);
            G.Nodes.allEigenvector(:,mIdx) = tempFile.infoDTI.eign_centrality(mIdx,:);
            G.Nodes.allBetweenness(:,mIdx) = tempFile.infoDTI.betw_centrality(mIdx,:); 
            G.Nodes.allClustercoef(:,mIdx) = tempFile.infoDTI.clustercoef(mIdx,:);
            G.Nodes.allParticipationcoef(:,mIdx) = tempFile.infoDTI.participationcoef(mIdx,:);
            G.Nodes.allEfficiency(:,mIdx) = tempFile.infoDTI.localEfficiency(mIdx,:);
            G.Nodes.FA0(:,mIdx) = tempFile.infoDTI.FA0(mIdx,:);
            G.Nodes.AD(:,mIdx) = tempFile.infoDTI.AD(mIdx,:);
            G.Nodes.MD(:,mIdx) = tempFile.infoDTI.MD(mIdx,:);
            G.Nodes.RD(:,mIdx) = tempFile.infoDTI.RD(mIdx,:);
        end
        graphCell{gIdx,dIdx} = G; 
    end
end

end





