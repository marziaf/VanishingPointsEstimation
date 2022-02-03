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
disp("Dataset located");

%% Pre-processing: get the lines
tic
%TODO work on all the images
refImg = imageData(1).imageFile;
segs = getSegments(refImg);
toc
disp("Segments extracted");

%% Extract vanishing points: J-linkage

% Obtain the preference matrix
preference = preferenceMatrix(segs);
disp("Preference matrix computed");

% Clustering
tic
clusters = jaccardClustering(preference, segs);
toc
disp("Edges clustered");

% Remove outliers
for k = keys(clusters)
    if size( clusters(k{1}).edges, 2 ) < 3
        remove(clusters, k{1});
        disp("Removed cluster " + str(k{1}) + " because it was outlier");
    end
end
disp("Checked for outliers");
%% Selection of meaningful directions

% Vanishing points of clusters (drop the old map for simplicity)
id = 1;
for oldId = keys(clusters)
    classification(id) = struct('vp', getClusterVPs(clusters(oldId{1}).edges), ...
        'edges', clusters(oldId{1}).edges);
    id = id + 1;
end
disp("Obtained cluster vanishing points");

manhDir = manhattanDirections(classification);
disp("Obtained manhattan directions");

%% Visual check

figure, imshow(refImg), hold on;
colors = ["red", "green", "blue"];
for k = 1:size(manhDir, 2)
    for e = 1:size(manhDir(k).edges, 1)
        edge = manhDir(k).edges(e, :);
        plot(edge(2:2:4), edge(1:2:4), Color=colors(k)); % TODO somewhere the coordinates are inverted
    end
end