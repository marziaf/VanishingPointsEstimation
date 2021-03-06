outDir = "../output";
datasetDir = "../dataset";
sourceImgDir = fullfile(datasetDir, "tvpd_dataset");

load( fullfile(outDir, 'extractedData.mat') );
load( fullfile(datasetDir, "camera_intrinsics.mat") );

outGraphDir = fullfile(outDir, "benchmarks");
if ~exist(outGraphDir, 'dir')
    mkdir(outGraphDir);
end


%% Compare the vanishing points with the ground truth
numImgs = size(data, 2) / 2;
% Store the difference between the ground truth vanishing points and the
% extracted ones
jaccardVpErrors = [];
tanimotoVpErrors = [];
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
    expVps = data(d).vps;
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
%% Compare the calibration matrices with ground truth
jaccadKFError = [];
tanimotoKFError = [];
jaccardKUVError = [];
tanimotoKUVError = [];
jaccUV = [];
taniUV = [];
jKcount = 0;
tKcount = 0;
gtF = K(1,1);
gtUV = K(1:2, 3);
for d = 1:size(data, 2)
    load(fullfile(sourceImgDir, data(d).image + ".mat"));
    if size(data(d).calibration,1) == 0; continue; end
    % Compare
    diffF = gtF - data(d).calibration(1,1);
    UV(1,1) = double(data(d).calibration(2, 3)); 
    UV(2,1) = double(data(d).calibration(1, 3));
    diffUV = gtUV - UV;
    if data(d).algorithm == algorithms.jaccard
        jKcount = jKcount + 1;
        jaccardKUVError(:, jKcount) = diffUV;
        jaccadKFError(jKcount) = diffF;
        jaccUV(:, jKcount) = UV;
    elseif data(d).algorithm == algorithms.tanimoto
        tKcount = tKcount + 1;
        tanimotoKUVError(:, tKcount) = diffUV;
        tanimotoKFError(tKcount) = diffF;
        taniUV(:, tKcount) = UV;
    end
end


%% Show data
%% VPS
set(0, 'DefaultFigureVisible', 'on');

%%
f = figure(); figure(f), title("Tanimoto vs Jaccard direction angular errors"), hold on, axis equal;
viscircles([0 0], 1, color='black');
viscircles([0 0], 2, color='black')
plot(tanimotoVpErrors(1,:), tanimotoVpErrors(2,:), 'ro');
plot(jaccardVpErrors(1,:), jaccardVpErrors(2,:), 'b*');
plot(0, 0, 'gx');
legend(["tanimoto error", "jaccard error", "ground truth"])

saveas(f, fullfile(outGraphDir, "angular_errors_vp"), 'png');
%%
f = figure(); figure(f), title("Angular error distribution Jaccard");
histogram2(jaccardVpErrors(1,:), jaccardVpErrors(2,:), BinWidth=0.1, DisplayStyle="tile");
colorbar;

saveas(f, fullfile(outGraphDir, "angular_errors_vp_dist_jacc"), 'png');

%%
f = figure(); figure(f), title("Angular error distribution Tanimoto");
histogram2(tanimotoVpErrors(1,:), tanimotoVpErrors(2,:), BinWidth=0.1, DisplayStyle="tile");
colorbar;

saveas(f, fullfile(outGraphDir, "angular_errors_vp_dist_tani"), 'png');

%% 
f = figure(); figure(f), title("Distance from ground truth Manhattan directions"), hold on;
histogram(vecnorm(tanimotoVpErrors), FaceColor='red', BinWidth=0.1, ...
    FaceAlpha=0.5, Normalization='probability');
histogram(vecnorm(jaccardVpErrors), FaceColor='blue', BinWidth=0.1, ...
    FaceAlpha=0.5, Normalization='probability');

medT = median(vecnorm(tanimotoVpErrors));
medJ = median(vecnorm(jaccardVpErrors));
meanT = mean(vecnorm(tanimotoVpErrors));
meanJ = mean(vecnorm(jaccardVpErrors));
line([ medT, medT ], [0 0.3], LineWidth=1, Color='red');
line([ medJ, medJ ], [0 0.3], LineWidth=1, Color='blue');
line([ meanT, meanT ], [0 0.3], LineWidth=1, Color='red', LineStyle='--');
line([ meanJ, meanJ ], [0 0.3], LineWidth=1, Color='blue', LineStyle='--');


legend(["tanimoto distance over " + string(size(tanimotoVpErrors, 2)) + " pts", ...
    "jaccard distance over " + string(size(jaccardVpErrors, 2)) + " pts", ...
    "tanimoto median", "jaccard median", "tanimoto mean", "jaccard mean"]);

saveas(f, fullfile(outGraphDir, "distance_errors_vp"), 'png');

%% 
f = figure(); figure(f), title("Focal distance error"), hold on;
histogram(tanimotoKFError, FaceColor='red', BinWidth=100, ...
    FaceAlpha=0.5, Normalization='probability');
histogram(jaccadKFError, FaceColor='blue', BinWidth=100, ...
    FaceAlpha=0.5, Normalization='probability');
legend("Tanimoto", "Jaccard")

saveas(f, fullfile(outGraphDir, "f_dist_err"), 'png');

%%
f = figure(); figure(f), title("Principal point distance error"), hold on;
histogram(vecnorm(tanimotoKUVError), FaceColor='red', BinWidth=200, ...
    FaceAlpha=0.5, Normalization='probability');
histogram(vecnorm(jaccardKUVError), FaceColor='blue', BinWidth=200, ...
    FaceAlpha=0.5, Normalization='probability');
legend("Tanimoto", "Jaccard")

saveas(f, fullfile(outGraphDir, "princ_point_dist_err"), 'png');

%%
f = figure(); figure(f), title("Principal point distribution"), hold on, axis equal;
rectangle(Position=[0 0 1920 1080]);
plot(jaccUV(1, :), jaccUV(2,:), 'bo');
plot(taniUV(1, :), taniUV(2, :), 'ro');
plot(gtUV(1), gtUV(2), "g*", LineWidth = 2, MarkerSize=20);

medJ = median(jaccUV, 2);
medT = median(taniUV, 2);

plot(medJ(1), medJ(2), "b*", LineWidth = 2, MarkerSize=20);
plot(medT(1), medT(2), "r*", LineWidth = 2, MarkerSize=20);


legend(["Jaccard over " + size(jaccUV, 2) + " K", ...
    "Tanimoto over " + size(taniUV, 2) + " K", ...
    "Ground truth", ...
    "Jaccard median", ...
    "Tanimoto median"]);

saveas(f, fullfile(outGraphDir, "princ_point_dist"), 'png');

%%

%%
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