function [clusters] = clustering(preference, edges, type)
    % clustering: cluster edges from preference matrix
    % preference: preference matrix relative to the edges
    % edges: the edges asssociated to the preference matrix
    % type: tanimoto or jaccard
    % returns: map of clusters
    %   map key: integer representing the id of the cluster
    %   map values: struct containing the centroid of the cluster (its 
    %   characteristic function) and the set of edges belonging to the
    %   cluster in shape [[x1, y1, x2, y2]; ...]
    arguments
        preference(:,:) {mustBeNumericOrLogical}
        edges(:, 4) {mustBeNumeric}
        type algorithms
    end
    
    %% Initialization
    numEdges = size(preference, 1);
    % Remember the association cluster-centroid-edges with a map
    clusters = containers.Map(-1, struct()); % TODO I really hope there is
    % a better way to define the types...
    remove(clusters, -1);
    for e = 1:numEdges
        clusters(e) = struct('centroid', preference(e, :), 'edges', edges(e,:));
    end
    % Keep a matrix with the distance between each cluster 
    % For simplicity, the distance with a deleted cluster is 2
    distances = ones(numEdges, numEdges) * 2;
    for c = 1:numEdges
        for r = 1:numEdges
            if (r ~= c)
                distances(r, c) = distance( clusters(r).centroid, clusters(c).centroid);
            end
        end
    end

    %% Clustering
    % Merge clusters with minimum jaccard distance until all distances are
    % 1 (or 2)
    minDist = min(distances(:));
    while minDist < 1
        [s1, s2] = find(distances == minDist);
        s1 = s1(1);
        s2 = s2(1);
        merge(s1, s2);
        minDist = min(distances(:));
    end




    function [d] = distance(s1, s2)
        if (type == algorithms.jaccard)
            d = algorithms.jaccardDistance(s1, s2);
        elseif (type == algorithms.tanimoto)
            d = algorithms.tanimotoDistance(s1, s2);
        else
            throw(MException("Invalid algorithm type"));
        end
    end

    function merge(s1, s2)
        % merge: merges two clusters
        % s1 & s2: edges id
        assert(s1 ~= s2);
        assert(isKey(clusters, s1) && isKey(clusters, s2));

        % find the centroid of the cluster (min of its members)
        if type == algorithms.jaccard
            newCentroid = clusters(s1).centroid & clusters(s2).centroid;
        elseif type == algorithms.tanimoto
            newCentroid = min([ clusters(s1).centroid; clusters(s2).centroid ]);
        end

        % merge the sets of edges
        newEdgesSet = [ clusters(s1).edges;  clusters(s2).edges ];

        % Put the new cluster in s1
        clusters(s1) = struct('centroid', newCentroid, 'edges', newEdgesSet);
        % delete merged
        remove(clusters, s2);

        for s = 1:numEdges
            % update distances with new cluster
            if isKey(clusters, s) && s ~= s1
                d = distance( clusters(s1).centroid, clusters(s).centroid);
                distances(s, s1) = d;
                distances(s1, s) = d; % symmetric matrix
            end
            % "delete" (set to 2) the distances with s2
            distances(s2, s) = 2;
            distances(s, s2) = 2;
        end
        
    end

end
