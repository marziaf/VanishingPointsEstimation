classdef algorithms
    methods(Static)
        %% CONSISTENCY
        function [c] = consistency(v, e)
            % consistency: consistency between vanishing point and edge
            % v: vanishing point
            % e: edge
            centroid = [mean([e(1) e(3); e(2) e(4)], 2); 1];
            l = cross(v, centroid);
            c = lineOps.distancePointLine([e(1); e(2); 1], l);
        end

        function [sc] = setConsistency(v, segs)
            % setConsistency: cumulative consistency of a vanishing point
            % with the set edges
            % v: vanishing point
            % segs: segments of a cluster
            sc = 0;
            for s=1:size(segs, 1)
                sc = sc + algorithms.consistency(v, segs(s, :));
            end
        end

        %% PREFERENCE MATRIX UTILS
        function [p] = jaccardPreferenceFun(v, e, thresh)
            % jaccardPreference: the function used to compute the 
            % preference matrix for jaccard algorithm
            % v: vanishing point [x; y; w]
            % e: edge [x1, y1, x2, y2]
            % thresh: threshold
            arguments
                v(1, 3) {mustBeNumeric}
                e(1, 4) {mustBeNumeric}
                thresh {mustBePositive}
            end
            p = algorithms.consistency(v, e) <= thresh;
        end
        
        function [phi] = tanimotoPreferenceFun(v, e, tau)
            % tanimotoPreference: the function used to compute the 
            % preference matrix for tanimoto algorithm
            % v: vanishing point [x; y; w]
            % e: edge [x1, y1, x2, y2]
            % tau: time constant
            arguments
                v(1, 3) {mustBeNumeric}
                e(1, 4) {mustBeNumeric}
                tau {mustBePositive}
            end
            d = algorithms.consistency(v, e);
            if d < 5 * tau
                phi = exp(-d/tau);
            else
                phi = 0;
            end
        end

        %% DISTANCES
        function [d] = jaccardDistance(s1, s2)
            % jaccardDistance: j. distance between sets
            % s1 & s2: characteristic function of the sets
            arguments
                s1(1,:) logical
                s2(1,:) logical
            end
            un = nnz(s1 | s2);
            in = nnz(s1 & s2);
            d = (un - in) / un;
        end

        function [d] = tanimotoDistance(s1, s2)
            % tanimotoDistance: t. distance between sets
            % s1 & s2: sets
            arguments
                s1(1,:) {mustBeNumeric}
                s2(1,:) {mustBeNumeric}
            end
            d = 1 - s1 * s2' / (norm(s1)^2 + norm(s2)^2 - s1 * s2');
        end
    end
    enumeration
        jaccard, tanimoto
    end
end

