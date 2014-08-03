function VMT = compute_vmt(D, V, L)
% D - density contour (m-by-n)
% V - speed contour (m-by-n)
% L - vector of link lengths (m-by-1)

[m, n] = size(D);

D = round(D.*repmat(L, 1, n)); % density -> vehicle count

VMT = (1/12) *  D .* V;
%VMT = round(VMT);

return;
