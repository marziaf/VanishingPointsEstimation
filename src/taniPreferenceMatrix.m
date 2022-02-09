function [preference] = taniPreferenceMatrix(segments, tau, numHyp, debugImg)
    % taniPreferenceMatrix: returns the preference matrix of the given minimal 
    % sample sets based on tanimoto distance
    % segments: the segments at the base of the matrix
    % tau: consistency threshold (opt)
    % numHyp: the number of hypothesis/vps to consider (opt)
    % debugImg: the image file name to use in debug (opt). If none, don't
    % show degug disp/plot
    % returns: preference matrix
    arguments
        segments(:,4) {mustBeNumeric}
        tau {mustBePositive} = 0.1 %TODO tune
        numHyp  {mustBePositive} = int16(size(segments, 1) ^ 1.3)
        debugImg {mustBeFile} = "taniPreferenceMatrix.m"; %TODO wow, such an awful solution
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

        % calculate the consistency of vp with all the edges
        for row=1:numEdges
            preference(row, col) = tConsensus(vp, segments(row, :));
        end
    end

    if debugImg ~= "taniPreferenceMatrix.m"
        figure, imshow(imread(debugImg)), hold on, axis auto;
        plot(vps(1,:) ./ vps(3,:), vps(2,:) ./ vps(3,:), 'ro');
    end 

function [phi] = tConsensus(v, e)
    % tConsensus: the tanimoto consensus for the preference matrix
    % v: vanishing point
    % e: edge
    d = consistency(v, e);
    if d < 5 * tau
        phi = exp(-d/tau);
    else
        phi = 0;
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




