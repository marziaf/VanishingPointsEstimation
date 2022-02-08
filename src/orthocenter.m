function [center] = orthocenter(A, B, C)
    % orthocenter: get the orthocenter of a triangle given its 2D corners
    % coordinates
    % a, b, c: coordinates of the corners [x, y]
    % returns the coordinates of the orthocenter
    arguments
        A(2,1) {mustBeNumeric}
        B(2,1) {mustBeNumeric}
        C(2,1) {mustBeNumeric}
    end
    AB = [B - A; 0];
    AC = [C - A; 0];
    BC = [C - B; 0];
    N = cross(AC, AB);
    L1 = cross(N, BC);
    L2 = cross(AC, N);
    P21 = AB;
    P1 = [A; 0];
    %
    ML = [L1 - L2];
    lambda = ML\P21;
    center = P1 + lambda(1) * L1;
    center = center(1:2);
end

