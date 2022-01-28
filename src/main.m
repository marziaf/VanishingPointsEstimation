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

%% Pre-processing: get the lines

%TODO work on all the images
segs = getSegments(imageData(1).imageFile);
disp("Segments extracted");
% Segments to homogeneous lines
lines = segToLine(segs);

%% Extract vanishing points: J-linkage

numSamples = size(lines, 2) ^ 2;
