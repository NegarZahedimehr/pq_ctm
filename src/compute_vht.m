function VHT = compute_vht(D, L)
% D - density contour (m-by-n)
% L - vector of link lengths (m-by-1)

[m, n] = size(D);

VHT = (1/12) * round(D.*repmat(L, 1, n));
%VHT = round(VHT);

return;
