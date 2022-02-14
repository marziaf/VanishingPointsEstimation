function [bestVp] = getClusterVPs(edges)
    % getClusterVPs: returns the vanishing point associated to a set of edges
    % edges: the edges of the cluster
    % returns: vanishing point (in homogeneous coordinates)
    arguments
        edges(:,4) {mustBeNumeric}
    end
    % Choose some possible vanishing points
    % Take the vanishing point with less sum of squared errors
    numEdges = size(edges, 1);
    assert(numEdges > 1);
    numRanVps = numEdges ^ 2;
    %
    bestVp = [0;0;0];
    minDist = Inf;
    for k = 1:numRanVps
        % random vp
        s1 = edges(randi(numEdges),:);
        s2 = edges(randi(numEdges),:);
        while s1 == s2
            s2 = edges(randi(numEdges),:);
        end
        vp = cross(lineOps.segToLine(s1), lineOps.segToLine(s2));
        % set consistency
        sc = algorithms.setConsistency(vp, edges);
        if sc < minDist
            minDist = sc;
            bestVp = vp;
        end
    end
    
end

