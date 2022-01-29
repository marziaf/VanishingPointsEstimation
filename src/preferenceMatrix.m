function [preference, vps] = preferenceMatrix(segments, numHyp, debugImg)
    % preferenceMatrix: returns the preference matrix of the given minimal 
    % sample sets
    % segments: the segments at the base of the matrix
    % numHyp: the number of hypothesis/vps to consider (opt)
    % debugImg: the image file name to use in debug (opt). If none, don't
    % show degug disp/plot
    % returns: preference matrix and hypothesis vanishing points
    arguments
        segments(:,4) {mustBeNumeric}
        %TODO parameter tuning for exponent
        numHyp  {mustBePositive} = int16(size(segments, 1) ^ 1.3)
        debugImg {mustBeFile} = "";
    end

    numEdges = size(segments, 1);
    preference = zeros(numEdges, numHyp);
    vps = zeros(3,numHyp);
    % iterate over columns/vanishing point hypothesis
    for col=1:numHyp
        % Select two distinct random edges
        s1 = segments(randi(numEdges),:);
        s2 = segments(randi(numEdges),:);
        while s1 == s2
            s2 = segments(randi(numEdges),:);
        end
        % calculate their corresponding vanishing point
        vp = vpEstimation2(segToLine(s1), segToLine(s2));
        vps(:,col) = vp;

        % calculate the consistency of vp with all the edges
        for row=1:numEdges
            preference(row, col) = consistency(vp, segments(row, :));
        end
    end

    if debugImg ~= ""
        figure, imshow(imread(debugImg)), hold on, axis auto;
        plot(vps(1,:) ./ vps(3,:), vps(2,:) ./ vps(3,:), 'ro');
    end 

end


function [line] = segToLine(seg)
    % SegToLine: given a segment, return the corresponding homogeneous line
    % seg: segment of the type [x1, y1, x2, y2]
    % returns: homogeneous line with same direction as segment
    arguments
        seg(1,4) {mustBeNumeric}
    end
    p1 = [seg(1:2)'; 1];
    p2 = [seg(3:4)'; 1];
    line = cross(p1, p2);
    line = line ./ norm(line);
end


function [vp] = vpEstimation2(l1, l2)
    % vpEstimation2: vanishing point estimation from two lines (no weight)
    % ( = cross product)
    % l1 & l2: lines in homogeneous coordinates
    vp = cross(l1, l2);
    vp = vp ./ norm(vp); % reduce numerical errors
end


function [c] = consistency(v, e)
    % consistency: consistency between vanishing point and edge
    % v: vanishing point (can't be at infinity)
    % e: edge
    centroid = [mean([e(1) e(3); e(2) e(4)], 2); 1];
    l = cross(v, centroid);
    c = distancePointLine([e(1); e(2); 1], l);
end


function d = distancePointLine(p, l)
    % distancePointLine
    % p: point in homo coord
    % l: line in homo coord
    assert(p(3) ~= 0);
    d = abs(l' * p) / sqrt(l(1)^2 + l(2)^2);
end