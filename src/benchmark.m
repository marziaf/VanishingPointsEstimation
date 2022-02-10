outDir = "../output";
datasetDir = "../dataset";
sourceImgDir = fullfile(datasetDir, "tvpd_dataset");

load( fullfile(outDir, 'extractedData.mat') );
load( fullfile(datasetDir, "camera_intrinsics.mat") );

%% Compare the vanishing points with the ground truth
numImgs = size(data, 2) / 2;
% Store the difference between the ground truth vanishing points and the
% extracted ones
%numVps = 
jaccardVpErrors = []; %zeros(2, 3*numImgs);
tanimotoVpErrors = []; %zeros(2, 3*numImgs);
vpCountJ = 0; vpCountT = 0;
for d = 1:size(data, 2)
    load(fullfile(sourceImgDir, data(d).image + ".mat"));

    % Get the vanishing points from the ground truth edges
    gtVps = zeros(3,3);
    for direction = 1:3
      gtVps(:, direction) = averageVP( ...
          double(segments( vp_association == direction, :)) );
    end
    % Find the differences between the axes directions in gt and
    % the experimental ones
    expVps = data(d).manhDirs;
    if size(expVps,1) == 0; continue; end
    % sanity check: delete possible NaN/Inf
    [~, sanitizec] = find(expVps == Inf | expVps == -Inf | isnan(expVps));
    expVps(:, sanitizec) = [];
    [~, sanitizec] = find(gtVps == Inf | gtVps == -Inf | isnan(gtVps)); %TODO I should not generate these
    gtVps(:, sanitizec) = [];
    % Extract directions
    expDir = expVps(1:2, :); expDir = expDir ./ vecnorm(expDir);
    tmp = expDir(1,:); expDir(1,:) = expDir(2,:); expDir(2,:) = tmp;
    gtDir = gtVps(1:2, :); gtDir = gtDir ./ vecnorm(gtDir);
    if size(gtVps, 2) == 3 % TODO this check is only temporary, remove
        for vix = 1:size(expDir, 2)
            % get closest and don't consider anymore
            cosSimilarity = acos(expDir(:, vix)' * gtDir); %TODO are coordinatres inverted?
            m = min(cosSimilarity);
            argm = find( cosSimilarity == m, 1 );
            dmin = gtDir(:, argm) - expDir(:, vix);
            gtDir(:, argm) = [];
            if data(d).algorithm == algorithms.jaccard && norm(dmin) <= 1 %TODO put this sanity check somewhere else
                vpCountJ = vpCountJ + 1;
                % sanity check
                jaccardVpErrors(:, vpCountJ) = dmin;
            elseif data(d).algorithm == algorithms.tanimoto && norm(dmin) <= 1
                vpCountT = vpCountT + 1;
                tanimotoVpErrors(:, vpCountT) = dmin;
            end
        end 
    end
end
%% Show data

%{
f1 = figure(); figure(f1), title("Jaccard vp errors"), hold on, axis equal;
plot(jaccardVpErrors(1,:), jaccardVpErrors(2,:), 'ro');
plot(0, 0, 'gx');
f2 = figure(); figure(f2), title("Tanimoto vp errors"), hold on, axis equal;
plot(tanimotoVpErrors(1,:), tanimotoVpErrors(2,:), 'ro');
plot(0, 0, 'gx');
%}
f3 = figure(); figure(f3), title("Tanimoto vs Jaccard vp errors"), hold on, axis equal;
viscircles([0 0], 1, color='black');
plot(tanimotoVpErrors(1,:), tanimotoVpErrors(2,:), 'ro');
plot(jaccardVpErrors(1,:), jaccardVpErrors(2,:), 'b*');
legend({'tanimoto error', 'jaccard error', 'ground truth'})
plot(0, 0, 'gx');


f4 = figure(); figure(f4), title("Distance from ground truth vanishing point"), hold on;
histogram(vecnorm(tanimotoVpErrors), FaceColor='red', NumBins=20, FaceAlpha=0.5);
histogram(vecnorm(jaccardVpErrors), FaceColor='blue', NumBins=20, FaceAlpha=0.5);
legend({'tanimoto distance', 'jaccard distance'});



set(0, 'DefaultFigureVisible', 'on');


function [aveVp] = averageVP(edges)
    % aveVp: average vanishing point between all the pairs of segments
    % edges
    numEdges = size(edges, 1);
    numVps = factorial(numEdges);
    aveVp = [0; 0; 0];
    for r = 1:numEdges
        for c = r+1:numEdges
            vp = cross(lineOps.segToLine(edges(r, :)), ...
                lineOps.segToLine( edges(c, :)) );
            vp = vp ./ vp(3); % important for the average of homo coord
            aveVp = aveVp + vp ./ numVps;
        end
    end
end