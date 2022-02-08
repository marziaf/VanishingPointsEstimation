function [segments] = getSegments(imgFile, minLength, debug)
    % getSegments: return an array of segments from the image
    % img: the image on which to extract the segments
    % minLength: minimal length for a segment (optional)
    % debug: activates debug outputs (optional)
    % returns: an array of the extreme points of the detected segments in the
    % shape [ [x1, y1, x2, y2]; ... ]
    
    arguments
        imgFile {mustBeFile}
        minLength {mustBeNumeric} = 100
        debug logical = false
    end
    
    % Load image and convert to grayscale
    img = imread(imgFile);
    img = rgb2gray(img);
    
    % Get edges and pixel classification
    [internal, endpoints, ~] = getGraphConnections(img, debug);
    % Navigate the connected components from their endpoints
    [startx, starty] = find(endpoints);
    segments = [];
    lenSeg = 0;
    % Navigation variables shared to improve performance
    visited = zeros(size(internal));
    deltaNeighbors = [[-1, -1]; [-1, 0]; [-1, 1]; [0, -1]; 
    [1, -1]; [1, 0]; [1, 1]; [0, 1]];
    for k=1:size(startx)
        from = [startx(k), starty(k)];
        [pts, len, track] = navigateSegment(from);
        if len > minLength
            % Fit line and check validity
            err = maxError(track, pts);
            if err <= 2      % less than 2 pixel error
                lenSeg = lenSeg + 1;
                segments(lenSeg, :) = pts;
            end
        end
    end

    if debug
        f = figure();
        figure(f), imshow(img), hold on;
        for k=1:size(segments, 1)
           plot([ segments(k,2), segments(k,4)], [segments(k,1), segments(k, 3)]);
        end
    end

function [endPoints, length, path] = navigateSegment(from)
    % navigateSegment: search on edges
    % from: coordinates of starting point [x,y]
    % graph: logic matrix representing the graph
    % returns:
    % endpoints of the path
    % the length of the path
    % coordinates containing the path

    current = from;
    length = 1;
    while current ~= [-1, -1]
        visited(current(1), current(2)) = true;
        path(length,:) = current;
        length = length + 1;
        found = false;
        % look for next in path
        for it=1:size(deltaNeighbors, 1)
            px = current(1) + deltaNeighbors(it,1);
            py = current(2) + deltaNeighbors(it,2);
            if inBound([px, py], size(internal)) && internal(px, py) == 1 && ~visited(px, py)
                current = [px, py];
                found = true;
                break
            end
        end
        % reached end
        if ~found
            endPoints = [from, current];
            current = [-1, -1];
        end
    end
    %[tx, ty] = find(visited);
    %track = [tx, ty];
end
end


function [internal, endpoints, junctions] = getGraphConnections(img, debug)
    % getGraphConnections: return classification masks for the edges

    % Canny edge detection
    edgesImg = edge(img, 'canny');
    if debug
        figure, imshow(edgesImg), title("Canny");
    end
    
    % Remove junctions by counting the white neighbours of a white pixel:
    % If the count is greater than 3, it's a junction,
    % If the count is 1, it's an end point

    mask = ones(3,3);
    mask(2,2) = 0;
    connectivityMap = conv2(edgesImg, mask, 'same');
    connectivityMap = connectivityMap .* edgesImg;
    junctions = connectivityMap > 3;
    endpoints = connectivityMap == 1;
    internal = edgesImg & ~junctions & ~endpoints;
    if debug
        rgb(:,:,1) = double(junctions);
        rgb(:,:,2) = double(endpoints);
        rgb(:,:,3) = double(internal);
        figure, imshow(rgb), title("Connectivity");
    end
end




function [inside] = inBound(p, bound)
    % inBound: return true if p is between [1,1] and bound
    % p: point [x,y]
    % bound: size of matrix [sx, sy]
    inside = p(1) >= 1 && p(1) <= bound(1) && ...
            p(2) >= 1 && p(2) <= bound(2);
end

function [maxError] = maxError(path, segmentEndpoints)
    maxError = -1;
    % maxError: find maximum distance between path and line
    m = ( segmentEndpoints(4) - segmentEndpoints(2)) /  ...
        ( segmentEndpoints(3) - segmentEndpoints(1));
    c = segmentEndpoints(4) - m * segmentEndpoints(3);
    for k=1:size(path, 1)
        maxError = max(maxError, distancePointLine(path(k, :), [m c]));
    end
end

function [d] = distancePointLine(p, l)
    % distancePointLine: distance between a point [x,y] and a 
    % line l=[a,b], with y=ax + b
    d = abs([l(1), -1, l(2)] * [p'; 1]) / sqrt(l(1)^2 + 1);
end