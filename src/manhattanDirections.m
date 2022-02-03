function [manhDir] = manhattanDirections(classes)
    % manhattanDirections: returns the sets of edges and their associated 
    % vanishing point for the three main directions
    % v: vanishing point
    % classes: struct array with parameters {vp, edges}, that is a set of
    % edges and its associated vanishing point
    arguments
        classes struct
    end

    % Trivial solution: take the 3 clusters with highest cardinality
    numClasses = size(classes,2);
    card = zeros(1,numClasses);
    for k = 1:numClasses
        card(k) = size(classes(k).edges, 1);
    end

    thresh = 0.05 * sum(card); % threshold for outliers
    for k = 1:min(3, numClasses)
        [M, idx] = max(card);
        if M < thresh
            break
        end
        card(idx) = -1; % Do not consider anymore
        manhDir(k) = classes(idx);
    end


    %{

    function [sc] = setConsistency(c1, c2)
        % setConsistency: distance between vanishing points
        % c1, c2: ids of the classes whose distance needs to be found
        vp = classes(c1).vp;
        S = classes(c2).edges;
        sc = 0;
        cardS = size(edges, 1);
        for e = 1:cardS
            sc = consistency(vp, S(e,:)) / cardS;
        end
    end

    %}
end

