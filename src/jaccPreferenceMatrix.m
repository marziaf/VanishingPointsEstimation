function [preference] = jaccPreferenceMatrix(segments, thresh, numHyp, debugImg)
    % jaccPreferenceMatrix: returns the preference matrix of the given minimal 
    % sample sets based on jaccard distance
    % segments: the segments at the base of the matrix
    % thresh: consistency threshold (opt)
    % numHyp: the number of hypothesis/vps to consider (opt)
    % debugImg: the image file name to use in debug (opt). If none, don't
    % show degug disp/plot
    % returns: preference matrix
    arguments
        segments(:,4) {mustBeNumeric}
        thresh {mustBePositive} = 10
        numHyp  {mustBePositive} = int16(size(segments, 1) ^ 1.3)
        debugImg {mustBeFile} = "jaccPreferenceMatrix.m"; %TODO wow, such an awful solution
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
            preference(row, col) = ...
                consistency(vp, segments(row, :)) <= thresh;
        end
    end

    if debugImg ~= "jaccPreferenceMatrix.m"
        figure, imshow(imread(debugImg)), hold on, axis auto;
        plot(vps(1,:) ./ vps(3,:), vps(2,:) ./ vps(3,:), 'ro');
    end 

end


function [vp] = vpEstimation2(l1, l2)
    % vpEstimation2: vanishing point estimation from two lines (no weight)
    % ( = cross product)
    % l1 & l2: lines in homogeneous coordinates
    vp = cross(l1, l2);
    vp = vp ./ norm(vp); % reduce numerical errors
end



