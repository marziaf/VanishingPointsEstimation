function [segments] = getSegments(imgFile, debug)
    % getSegments: return an array of segments from the image
    % img: the image on which to extract the segments
    % debug: activates debug outputs
    % returns: an array of the extreme points of the detected segments in the
    % shape [ [x1, y1, x2, y2]; ... ]
    
    arguments
        imgFile {mustBeFile}
        debug logical = false
    end
    
    % Load image and convert to grayscale
    img = imread(imgFile);
    img = rgb2gray(img);
    
    % Get edges and pixel classification
    [internal, endpoints, junctions] = getGraphConnections(img, debug);

end

function [internal, endpoints, junctions] = getGraphConnections(img, debug)
    % Canny edge detection
    edgesImg = edge(img, 'canny');
    if debug
        figure, imshow(edgesImg), title("Canny");
    end
    
    % Remove junctions by counting the white neighbours of a white pixel:
    % If the count is greater than 3, it's a junction,
    % If the count is 1, it's an end point
    
    % TODO implement with convolution
    % mask:
    % 111
    % 101
    % 111
    mask = ones(3,3);
    mask(2,2) = 0;
    connectivityMap = conv2(edgesImg, mask, 'same');
    connectivityMap = connectivityMap .* edgesImg;
    junctions = connectivityMap > 2;
    endpoints = connectivityMap == 1;
    internal = edgesImg & ~junctions & ~endpoints;
    if debug
        rgb(:,:,1) = double(junctions);
        rgb(:,:,2) = double(endpoints);
        rgb(:,:,3) = double(internal);
        figure, imshow(rgb), title("Connectivity");
    end
end