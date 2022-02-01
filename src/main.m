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

%TODO work on all the images
refImg = imageData(1).imageFile;
segs = getSegments(refImg);
disp("Segments extracted");

%% Extract vanishing points: J-linkage

% Obtain the preference matrix
preference = preferenceMatrix(segs);
disp("Preference matrix computed");

% cluster
clusters = jaccardClustering(preference, segs);
disp("Edges clustered");