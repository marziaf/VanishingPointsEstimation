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

    % Get the direction of the average vanishing point from the ground 
    % truth edges
    gtDir = zeros(2,3);
    for direction = 1:3
      gtDir(:, direction) = edgesDirection( ...
          double(segments( vp_association == direction, :)) );
    end
    % Get the direction of the vanishing points of the experimental data
    expVps = data(d).manhDirs;
    if size(expVps,1) == 0; continue; end
    % sanity check: delete possible NaN/Inf
    [~, sanitizec] = find(expVps == Inf | expVps == -Inf | isnan(expVps));
    expVps(:, sanitizec) = []; 
    % Extract directions
    expDir = expVps(1:2, :); expDir = expDir ./ vecnorm(expDir);
    tmp = expDir(1,:); expDir(1,:) = expDir(2,:); expDir(2,:) = tmp;
    % match vanishing points
    matches = matchDirections(expDir, gtDir);
    % find the distance between matched vps
    dmin = matches.w - matches.v;
    numVps = size(matches.v, 2);
    if data(d).algorithm == algorithms.jaccard
        % sanity check
        jaccardVpErrors(:, vpCountJ + (1:numVps)) = dmin;
        vpCountJ = vpCountJ + numVps;
    elseif data(d).algorithm == algorithms.tanimoto
        tanimotoVpErrors(:, vpCountT + (1:numVps)) = dmin;
        vpCountT = vpCountT + numVps;
    end 

end
%% Show data

f3 = figure(); figure(f3), title("Tanimoto vs Jaccard vp errors"), hold on, axis equal;
viscircles([0 0], 1, color='black');
viscircles([0 0], 2, color='black')
plot(tanimotoVpErrors(1,:), tanimotoVpErrors(2,:), 'ro');
plot(jaccardVpErrors(1,:), jaccardVpErrors(2,:), 'b*');
plot(0, 0, 'gx');
legend(["tanimoto error", "jaccard error", "ground truth"])


f4 = figure(); figure(f4), title("Distance from ground truth vanishing point"), hold on;
histogram(vecnorm(tanimotoVpErrors), FaceColor='red', NumBins=20, FaceAlpha=0.5);
histogram(vecnorm(jaccardVpErrors), FaceColor='blue', NumBins=20, FaceAlpha=0.5);
legend(["tanimoto distance over " + string(size(tanimotoVpErrors, 2)) + " pts", ...
    "jaccard distance " + string(size(jaccardVpErrors, 2)) + " pts"]);



set(0, 'DefaultFigureVisible', 'on');


function [dir] = edgesDirection(edges)
    % edgesDirection: average direction of the edges
    numEdges = size(edges, 1);
    dir = [0; 0];
    for r = 1:numEdges
        for c = r+1:numEdges
            vp = cross(lineOps.segToLine(edges(r, :)), ...
                lineOps.segToLine( edges(c, :)) );
            d = vp(1:2);
            dir = dir + d ./ norm(d);
        end
    end
    dir = dir ./ norm(dir); % normalize
end


function [matches] = matchDirections(v, w)
    % matchDirections: find the pairs with maximum cumulative energy 
    % (distance) between the vp directions
    permv = perms(1:size(v, 2));
    permw = perms(1:size(w, 2));
    minSize = min(size(v, 2), size(w, 2));
    % test every possible permutation
    maxEnergy = -1;
    matches = struct('v', [], 'w', []);
    for pvid = 1:size(permv, 1)
        pv = permv(pvid, :);
        for pwid = 1:size(permw, 1)
            pw = permw(pwid, :);
            e = energy(pv, pw);
            if e > maxEnergy
                maxEnergy = e;
                matches = struct('v', v(:, pv(:, 1:minSize)), ...
                    'w', w(:, pw(:, 1:minSize)));
            end
        end

    end
    
    function [e] = energy(pv, pw)
        % quadratic energy function of a permutation
        e = 0;
        for k = 1:minSize
            % the evergy of a couple is the square of the angular distance
            % between the vectors centered around angle x (so that angle x 
            % has the minimum energy)
            center = pi / 2 + pi / 4;
            e = e + abs( acos( v(:, pv(k))' * w(:, pw(k)) ) - center) ^ 2;
        end
    end

end