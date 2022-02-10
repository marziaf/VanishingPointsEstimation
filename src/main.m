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
refImg = imageData(60).imageFile;
segs = getSegments(refImg);
%{
bw = rgb2gray(imread(refImg));
[H, theta, rho] = hough(bw); 
hgPeaks = houghpeaks(H, 200, 'Theta', theta, 'Threshold', 0.05 * max(H(:)));     % identify the peaks in the diagram, which correspond to candidate lines
hgLines = houghlines(bw, theta, rho, hgPeaks,'FillGap', 3);
numLines = size(hgLines, 2);
segs = zeros(numLines, 4);
for k = 1:numLines
    segs(k, :) = [hgLines(k).point1, hgLines(k).point2];
end
%}
t = toc;
disp("Segments extracted in " + t + " sec");

%% Extract vanishing points: J-linkage

% Obtain the preference matrix
preference = preferenceMatrix(segs);
disp("Preference matrix computed");

% Clustering
tic
clusters = jaccardClustering(preference, segs);
t = toc;
disp("Edges clustered in " + t + " sec");

% Remove outliers
for k = keys(clusters)
    if size( clusters(k{1}).edges, 1 ) < 3
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

%% Calibration
hasBeenCalibrated = false;
if size(manhDir, 2) == 3
    vps = [ manhDir(1).vp manhDir(2).vp manhDir(3).vp ];
    vps = vps ./ vps(3,:);

    % Impose orthogonality
    syms u0s v0s fs; % a = 1 -> fx=fy
    Kest = [ fs 0 u0s; 0 fs v0s; 0 0 1];
    %omega = inv(Kest * Kest');
    omega = [1, 0, -u0s; 0, 1, -v0s; -u0s, - v0s, fs^2 + u0s^2 + v0s^2];
    sys = [ vps(:,1).' * omega * vps(:,2) == 0, ...
        vps(:,1).' * omega * vps(:,3) == 0, vps(:,2).' * omega * vps(:,3) == 0 ];
    S = solve(sys, [u0s, v0s, fs], Real=true);
    if ~isempty(S.u0s)
        % of the two solutions, take the one with positive focal distance
        k = find(S.fs > 0, 1);
        % principal point
        u0 = double( S.u0s(k) );
        v0 = double( S.v0s(k) );
        % focal distance
        f = double( S.fs(k) );
        % K
        Kest = subs(Kest, u0s, u0);
        Kest = subs(Kest, v0s, v0);
        Kest = subs(Kest, fs, f);
        hasBeenCalibrated = true;
    end
else
    disp("Not enough vanishing points extracted to calibrate the image!")
end


%% Visual check

figure(Visible="on"), imshow(refImg), hold on, axis auto;
if hasBeenCalibrated 
    plot(v0, u0, Color='yellow', Marker="*", MarkerSize=20, LineWidth=5)
end
colors = ["red", "green", "blue"];
for k = 1:size(manhDir, 2)
    for e = 1:size(manhDir(k).edges, 1)
        edge = manhDir(k).edges(e, :);
        plot(edge(2:2:4), edge(1:2:4), Color=colors(k)); % TODO somewhere the coordinates are inverted
        v = manhDir(k).vp;
        %plot(v(2) / v(3), v(1) / v(3), Color=colors(k), Marker="+", MarkerSize=20, LineWidth=5);
    end
end
