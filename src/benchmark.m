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
    % Find the differences between the clostest vanishing points in gt and
    % the experimental ones
    expVps = data(d).manhDirs;
    expVps = expVps(1:2, :) ./ expVps(3, :);
    gtVps = gtVps(1:2, :) ./ gtVps(3, :);
    for vix = 1:data(k).numVps
        % get closest and don't consider anymore
        diff = [];
        diff(1, :) = gtVps(1, :) - expVps(2, vix);
        diff(2, :) = gtVps(2, :) - expVps(1, vix);
        sqdiff = diff(1,:).^2 + diff(2,:).^2;
        m = min(sqdiff);
        argm = find( sqdiff == m, 1 );
        gtVps(:, argm) = [];
        if data(d).algorithm == algorithms.jaccard
            vpCountJ = vpCountJ + 1;
            jaccardVpErrors(:, vpCountJ) = diff(:, argm);
        elseif data(d).algorithm == algorithms.tanimoto
            vpCountT = vpCountT + 1;
            tanimotoVpErrors(:, vpCountT) = diff(:, argm);
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
plot(tanimotoVpErrors(1,:), tanimotoVpErrors(2,:), 'ro');
plot(jaccardVpErrors(1,:), jaccardVpErrors(2,:), 'b*');
legend({'tanimoto error', 'jaccard error', 'ground truth'})
plot(0, 0, 'gx');


f4 = figure(); figure(f4), title("Distance from ground truth vanishing point"), hold on;
histogram(sqrt( tanimotoVpErrors(1,:) .^2 + tanimotoVpErrors(2,:).^2 ), FaceColor='red', BinWidth=500, FaceAlpha=0.5);
histogram(sqrt( jaccardVpErrors(1,:) .^2 + jaccardVpErrors(2,:).^2 ), FaceColor='blue', BinWidth=500, FaceAlpha=0.5);
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