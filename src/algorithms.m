classdef algorithms
    methods(Static)
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
            p = consistency(v, e) <= thresh;
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
            d = consistency(v, e);
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

