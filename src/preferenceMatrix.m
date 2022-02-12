function [preference] = preferenceMatrix(segments, type, thresh, numHyp, debugImg)
    % preferenceMatrix: returns the preference matrix of the given minimal 
    % sample sets based on jaccard or tanimoto distance
    % segments: the segments at the base of the matrix
    % type: jaccard or tanimoto
    % thresh: consistency threshold for jaccard or time constant for tanimoto (opt)
    % numHyp: the number of hypothesis/vps to consider (opt)
    % debugImg: the image file name to use in debug (opt). If none, don't
    % show degug disp/plot
    % returns: preference matrix
    arguments
        segments(:,4) {mustBeNumeric}
        type algorithms
        thresh {mustBePositive} = autoThresh(type)
        numHyp  {mustBePositive} = 500 %int16(size(segments, 1) ^ 1.3)
        debugImg {mustBeFile} = "preferenceMatrix.m"; %TODO wow, such an awful solution
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
        vp = vpEstimation2(lineOps.segToLine(s1), lineOps.segToLine(s2));
        vps(:,col) = vp;

        % calculate the consistency of vp with all the edges and fill
        % preference matrix
        for row=1:numEdges
            preference(row, col) = preferenceFunction(vp, segments(row, :));
        end
    end

    if debugImg ~= "preferenceMatrix.m"
        figure, imshow(imread(debugImg)), hold on, axis auto;
        plot(vps(1,:) ./ vps(3,:), vps(2,:) ./ vps(3,:), 'ro');
    end 


    function [p] = preferenceFunction(v, e)
        if (type == algorithms.jaccard)
            p = algorithms.jaccardPreferenceFun(v, e, thresh);
        elseif (type == algorithms.tanimoto)
            p = algorithms.tanimotoPreferenceFun(v, e, thresh);
        else
            throw(MException("Invalid algorithm type"));
        end
    end
end


function [vp] = vpEstimation2(l1, l2)
    % vpEstimation2: vanishing point estimation from two lines (no weight)
    % ( = cross product)
    % l1 & l2: lines in homogeneous coordinates
    vp = cross(l1, l2);
    vp = vp ./ norm(vp); % reduce numerical errors
end


function [t] = autoThresh(type)
    % Automatic threshold if none indicated
    if type == algorithms.jaccard
        t = 10;
    elseif type == algorithms.tanimoto
        t = 0.5;
    else
        throw(MException("Invalid algorithm type"));
    end
end


