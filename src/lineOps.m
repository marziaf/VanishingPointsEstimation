classdef lineOps
    methods(Static)
        function [line] = segToLine(seg)
            % SegToLine: given a segment, return the corresponding homogeneous line
            % seg: segment of the type [x1, y1, x2, y2]
            % returns: homogeneous line with same direction as segment
            arguments
                seg(1,4) {mustBeNumeric}
            end
            p1 = [seg(1:2)'; 1];
            p2 = [seg(3:4)'; 1];
            line = cross(p1, p2);
            line = line ./ norm(line);
        end

        function d = distancePointLine(p, l)
            % distancePointLine
            % p: point in homo coord
            % l: line in homo coord
            arguments
                p(3,1) {mustBeNumeric}
                l(3,1) {mustBeNumeric}
            end
            %assert(p(3) ~= 0);
            d = abs(l' * p) / sqrt(l(1)^2 + l(2)^2);
        end
    end
end
