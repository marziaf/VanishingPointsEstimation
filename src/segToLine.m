function [lines] = segToLine(segs, debug)
    % SegToLine: given a set of segments, return the corresponding homogeneous
    % lines
    % segs: list of segments of the type [[x1, y1, x2, y2]; ...]
    % debug: activate debug outputs
    % returns: homogeneous lines of the type [[a; b; c], ...]
    arguments
        segs(:, 4) {mustBeNumeric}
        debug logical = false
    end

    lines = zeros(3, size(segs,1));
    for k= 1:size(segs)
        m = ( segs(k,4) - segs(k,2)) /  ...
            ( segs(k,3) - segs(k,1));
        c = segs(k,4) - m * segs(k,3);
        lines(:, k) = [m; -1; c];
        if debug
            disp(segs(k, :));
            disp(lines(k, :));
        end
    end
end

