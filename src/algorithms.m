classdef algorithms
    methods(Static)
        % PREFERENCE MATRIX UTILS
        function [p] = jaccardPreferenceFun(v, e, thresh)
            % jaccardPreference: the function used to compute the 
            % preference matrix for jaccard algorithm
            % v: vanishing point [x; y; w]
            % e: edge [x1, y1, x2, y2]
            % thresh: threshold
            p = consistency(v, e) <= thresh;
        end
        
        function [phi] = tanimotoPreferenceFun(v, e, tau)
            % tanimotoPreference: the function used to compute the 
            % preference matrix for tanimoto algorithm
            % v: vanishing point [x; y; w]
            % e: edge [x1, y1, x2, y2]
            % tau: time constant
            d = consistency(v, e);
            if d < 5 * tau
                phi = exp(-d/tau);
            else
                phi = 0;
            end
        end
    end
    enumeration
        jaccard, tanimoto
    end
end

