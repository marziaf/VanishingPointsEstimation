%% Prepare dataset files
datasetDir = "../dataset/tvpd_dataset/";
imageFileNames = dir(fullfile(datasetDir, "*.jpg"));
% Store file names to be loaded in execution (.jpg and .mat)
imageData = struct("imageFile", [], "imageGTFile", []);
for k=1:size(imageFileNames)
    imageData(k).imageFile = ...
        fullfile(imageFileNames(k).folder, imageFileNames(k).name);
    [~, basename, ~] = fileparts(imageFileNames(k).name);
    imageData(k).imageGTFile = ...
        fullfile(imageFileNames(k).folder, strcat(basename, '.mat'));
end

outDir = "../output";
outDirCluster = fullfile(outDir, "clustering");
outDirImJ = fullfile(outDirCluster, "jaccImg");
outDirImT = fullfile(outDirCluster, "taniImg");
if ~exist(outDirImT, 'dir')
    mkdir(outDirImT);
end
if ~exist(outDirImJ, 'dir')
    mkdir(outDirImJ);
end
disp("Dataset located");

set(0, 'DefaultFigureVisible', 'off');
idxData = 0;
data = struct('image', [], 'algorithm', [], 'clusters', struct('vp', [], 'edges', []), 'vps', [], 'calibration', []);
imNum = size(imageData, 2);
for imID = 1:imNum
    disp("------ " + string(imID * 100 / imNum) + "% -----");
    %% Pre-processing: get the lines
    refImg = imageData(imID).imageFile;
    [~, name, ~] = fileparts(refImg);
    disp("WORKING ON IMAGE " + name);
    tic
    segs = []; assert (size(segs, 1) == 0);
    segs = getSegments(refImg);
    t = toc;
    disp("> Segments extracted in " + t + " seconds");

    for algorithm = [algorithms.jaccard, algorithms.tanimoto]
        rng('default');
        disp(">> Algorithm " + string(algorithm));
        %% Extract vanishing points: J-linkage
        
        % Obtain the preference matrix
        preference = preferenceMatrix(segs, algorithm);
        disp("Preference matrix computed");
        
        % Clustering
        tic
        clusters = clustering(preference, segs, algorithm);
        t = toc;
        disp("> Edges clustered in " + t + " sec");
        
        % Remove outliers
        for k = keys(clusters)
            if size( clusters(k{1}).edges, 1 ) < 3
                remove(clusters, k{1});
                disp("Removed cluster " + string(k{1}) + " because it was outlier");
            end
        end
        disp("Checked for outlier clusters");
        %% Selection of meaningful directions
        
        % Vanishing points of clusters (drop the old map for simplicity)
        id = 1;
        classification = struct('vp', [], 'edges', []);
        for oldId = keys(clusters)
            classification(id) = struct('vp', getClusterVPs(clusters(oldId{1}).edges), ...
                'edges', clusters(oldId{1}).edges);
            id = id + 1;
        end
        disp("Obtained cluster vanishing points");
        
        manhDir = manhattanDirections(classification);
        disp("> Obtained manhattan directions");
        %% Store data
        idxData = idxData + 1;
        data(idxData) = struct('image', name, 'algorithm', algorithm, 'clusters', manhDir,  'vps', [ manhDir.vp ], 'calibration', []);

        %% Backup save every x images
        if mod(imID, 10) == 0
            disp("Data backup");
            save(fullfile(outDir, 'extractedData'), 'data');
        end
        %% Visual check
        
        f = figure(Visible="off"); 
        set(0, 'currentfigure', f);
        if algorithm == algorithms.jaccard
            outFile = fullfile(outDirImJ, name);
        else
            outFile = fullfile(outDirImT, name);
        end
        imshow(refImg), hold on, title( ...
            name + " -- " + string(algorithm), Interpreter="none");
        colors = ["red", "green", "blue"];
        if ~isempty(manhDir(1).vp)
            for k = 1:size(manhDir, 2)
                plot([manhDir(k).edges(:, 2), manhDir(k).edges(:, 4)]', ...
                    [manhDir(k).edges(:, 1), manhDir(k).edges(:, 3)]', ...
                    Color=colors(k), LineWidth=2);
            end
        end
        disp("Saving " + name + " - " + string(algorithm));
        saveas(f, outFile, 'png'); 
        
    end
end

disp("Saving data");
save(fullfile(outDir, 'extractedData'), 'data');
