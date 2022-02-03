function [c] = consistency(v, e)
    % consistency: consistency between vanishing point and edge
    % v: vanishing point
    % e: edge
    centroid = [mean([e(1) e(3); e(2) e(4)], 2); 1];
    l = cross(v, centroid);
    c = lineOps.distancePointLine([e(1); e(2); 1], l);
end