outDir = "../output";
datasetDir = "../dataset";
sourceImgDir = fullfile(datasetDir, "tvpd_dataset");

dataFile = fullfile(outDir, 'extractedData.mat');
load( dataFile );

%% Calibration

for d = 1:size(data, 2)
    if mod(d, 10) == 0
        disp(d*100/size(data,2));
    end
    hasBeenCalibrated = false;
    % sanity check: delete possible NaN/Inf
    [~, sanitizec] = find(data(d).manhDirs == Inf | data(d).manhDirs == -Inf | isnan(data(d).manhDirs));
    data(d).manhDirs(:, sanitizec) = []; 

    % Check if calibration is possible
    if size(data(d).manhDirs, 2) < 3; continue; end

    vps = data(d).manhDirs;
    vps = vps ./ vecnorm(vps);
    % Impose orthogonality
    data(d).calibration = findKauto(vps(:,1), vps(:,2), vps(:,3));

    save(dataFile, "data"); %TODO
end

disp("Calibration complete")


function [K] = findK(v1, v2, v3)
    % Calculates the calibration matrix from 3 vanishing points
    v = [v1 v2; v1 v3; v2 v3];
    A = zeros(3, 3);
    for k = 1:3
        vi = v(3*(k-1) + (1:3) , 1);
        vj = v(3*(k-1) + (1:3), 2);
        A(k, :) = [ 
            %vi(1) * vj(1) + vi(2) * vj(2), ...
            vi(2) * vj(2) + vi(1) * vj(3), ...
            vi(3) * vj(2) + vi(2) * vj(3), ...
            vi(3) * vj(3), ...
        ];
    end
    [~, ~, O] = svd(A);
    % iac parameters to reshape
    o = O(:, end);
    u = -o(1);
    v = -o(2);
    f = sqrt(o(3) - (u + v));
    K = [f 0 u; 0 f v; 0 0 10^-3];
end


function [K] = findKauto(v1, v2, v3)
    syms u0s v0s fs; % a = 1 -> fx=fy
    K = [ fs 0 u0s; 0 fs v0s; 0 0 1];
    omega = inv(K * K');
    %mega = [1, 0, -u0s; 0, 1, -v0s; -u0s, - v0s, fs^2 + u0s^2 + v0s^2];
    sys = [ v1.' * omega * v2 == 0, ...
        v1.' * omega * v3 == 0, v2.' * omega * v3 == 0 ];
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
        K = subs(K, u0s, u0);
        K = subs(K, v0s, v0);
        K = double(subs(K, fs, f));
    else
        K = [];
    end

end