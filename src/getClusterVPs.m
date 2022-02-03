function [vp] = getClusterVPs(edges)
    % getClusterVPs: returns the vanishing point associated to a set of edges
    % edges: the edges of the cluster
    % w: ??? TODO
    % returns: vanishing point (in homogeneous coordinates)
    arguments
        edges(:,4) {mustBeNumeric}
        %w(1, :) {mustBeNumeric}
    end
    
    % TODO tmp solution: average of randomly selected vps
    numEdges = size(edges, 1);
    numRanVps = 2 * numEdges;
    randVps = zeros(3, numRanVps);
    for k = 1:numRanVps
        s1 = edges(randi(numEdges),:);
        s2 = edges(randi(numEdges),:);
        while s1 == s2
            s2 = edges(randi(numEdges),:);
        end
        randVps(:, k) = cross(lineOps.segToLine(s1), lineOps.segToLine(s2));
    end
    vp = mean(randVps, 2);
end
%{
    % symbolic distance point line
    dist = @(l,p) abs(l' * p) / sqrt(l(1)^2 + l(2)^2); 
    % skew matrix
    skew = @(e) [0 -e(3) e(2); e(3) 0 -e(1); -e(2) e(1) 0];

    % minimization function
    v = sym('v', [3, 1]); k = sym('k');
    numEdges = size(edges, 1);
    em = [ (edges(:,1)-edges(:,3)) / 2, (edges(:,2)-edges(:,4)), ones(numEdges,1) ]';
    e1 = [edges(:,1), edges(:,3), ones(numEdges, 1)]';
    k=1
    s = subs( w(k).^2 * dist( skew(em(:,k)) * v, e1(:,k) ), k, [1 numEdges] );
    S(v) = sum(s);

    vp = fminsearch(obj, [0 0 0]);

end
%}

