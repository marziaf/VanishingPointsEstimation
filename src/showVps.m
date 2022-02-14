outDir = "../output";
outAxesDir = fullfile(outDir, "manhDirs");
outAxJacc = fullfile(outAxesDir, "jaccAx");
outAxTani = fullfile(outAxesDir, "taniAx");

if ~exist(outAxJacc, 'dir')
    mkdir(outAxJacc);
end

if ~exist(outAxTani, 'dir')
    mkdir(outAxTani);
end

datasetDir = "../dataset";
sourceImgDir = fullfile(datasetDir, "tvpd_dataset");

load( fullfile(outDir, 'extractedData.mat') );

set(0, 'DefaultFigureVisible', 'off');

s = [3291, 1830];
colors = ["red", "green", "blue"];

% overlay extracted directions
for d = 1: 6% TODOsize(data, 2)
    load(fullfile(sourceImgDir, data(d).image + ".mat"));
    img = imread(fullfile(outDir, "jaccImg", data(d).image + ".png"));
    vpHomo = data(d).vps;
    dir = vpHomo(1:2,:);
    numVps = size(dir,2);
    linesx = zeros(numVps, 2);
    linesy = zeros(numVps, 2);
    for v=1:numVps
        a = dir(1,v);
        b = dir(2,v);
        c = - a * s(1) ./ 2 - b * s(2) ./ 2;
        [linesx(v, :), linesy(v, :)] = lineEqToSeg(a, b, c, s);
    end

    f = figure(Visible="off"); set(0, 'currentfigure', f);
    imshow(img), hold on, title(data(d).image), axis auto;
    for k=1:numVps
        plot(linesx(k,:)', linesy(k, :)', Color=colors(k), LineWidth=5);
    end

    if data(d).algorithm == algorithms.jaccard
        outFile = fullfile(outAxJacc, data(d).image);
    else
        outFile = fullfile(outAxTani, data(d).image);
    end
    disp("Saving " + outFile)
    saveas(f, outFile, 'png')

end

function [x, y] = lineEqToSeg(a, b, c, s)
    % segment of line ax + by + c = 0 in the range between [0 0] and s
    x = [ s(1) / 2, s(1)];
    if ( b ~= 0 && a ~= 0) % not vertical, not horizontal
        y2 = -(a/b) * s(1) - c/b;
        if y2 > s(2) || y2 < 0 % out of image
            if y2 > s(2)
                y2 = s(2); 
            else 
                y2 = 0;
            end
            x(2) = - (b / a) * y2 - c/a;
        end
        y = [ s(2) ./ 2, y2 ];
        
    elseif a == 0 % horizontal
        y = [ -c/b, -c/b];

    else % vertical
        x = [ -c/a, -c/a ];
        y = [ s(2) / 2, s(2) ];
    end

end


