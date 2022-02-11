outDir = "../output";
datasetDir = "../dataset";
sourceImgDir = fullfile(datasetDir, "tvpd_dataset");

load( fullfile(outDir, 'extractedData.mat') );

%% Calibration

for d = 1:size(data, 2)
 
    hasBeenCalibrated = false;
    % sanity check: delete possible NaN/Inf
    [~, sanitizec] = find(data(d).manhDirs == Inf | data(d).manhDirs == -Inf | isnan(data(d).manhDirs));
    data(d).manhDirs(:, sanitizec) = []; 

    % Check if calibration is possible
    if size(data(d).manhDirs, 2) < 3; continue; end

    vps = data(d).manhDirs;
    
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
 end