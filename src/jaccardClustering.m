function [clusters] = jaccardClustering(preference, edges)
    % jaccardClustering: cluster edges from preference matrix
    % preference: preference matrix relative to the edges
    % edges: the edges asssociated to the preference matrix
    % returns: map of clusters
    %   map key: integer representing the id of the cluster
    %   map values: struct containing the centroid of the cluster (its 
    %   characteristic function) and the set of edges belonging to the
    %   cluster in shape [[x1, y1, x2, y2]; ...]
    arguments
        preference(:,:) logical
        edges(:, 4) {mustBeNumeric}
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
                distances(r, c) = jaccardDistance( ...
                    clusters(r).centroid, clusters(c).centroid);
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


    function merge(s1, s2)
        % merge: merges two clusters
        % s1 & s2: edges id
        assert(s1 ~= s2);
        assert(isKey(clusters, s1) && isKey(clusters, s2));

        % find the centroid of the cluster (intersection of its members)
        newCentroid = clusters(s1).centroid & clusters(s2).centroid;
        % merge the sets of edges
        newEdgesSet = [ clusters(s1).edges;  clusters(s2).edges ];
        % Put the new cluster in s1
        clusters(s1) = struct('centroid', newCentroid, 'edges', newEdgesSet);
        % delete merged
        remove(clusters, s2);

        for s = 1:numEdges
            % update distances with new cluster
            if isKey(clusters, s) && s ~= s1
                d = jaccardDistance( ...
                    clusters(s1).centroid, clusters(s).centroid);
                distances(s, s1) = d;
                distances(s1, s) = d; % symmetric matrix
            end
            % "delete" (set to 2) the distances with s2
            distances(s2, s) = 2;
            distances(s, s2) = 2;
        end
    end

end


function [d] = jaccardDistance(s1, s2)
    % jaccardDistance: j. distance between sets
    % s1 & s2: characteristic function of the sets
    un = nnz(s1 | s2);
    in = nnz(s1 & s2);
    d = (un - in) / un;
end


