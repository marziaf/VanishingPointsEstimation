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
outDirImJ = fullfile(outDir, "jaccImg");
outDirImT = fullfile(outDir, "taniImg");
if ~exist(outDirImT, 'dir')
    mkdir(outDirImT);
end
if ~exist(outDirImJ, 'dir')
    mkdir(outDirImJ);
end
disp("Dataset located");

set(0, 'DefaultFigureVisible', 'off');


for imID = 1:size(imageData, 2)
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
        for k = 1:size(manhDir, 2)
            plot([manhDir(k).edges(:, 2), manhDir(k).edges(:, 4)]', ...
                [manhDir(k).edges(:, 1), manhDir(k).edges(:, 3)]', ...
                Color=colors(k), LineWidth=2);
        end
        disp("Saving " + name + " - " + string(algorithm));
        saveas(f, outFile, 'png');
    end
end
