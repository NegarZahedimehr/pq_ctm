function DLY = compute_delay(VMT, VHT, FFV)
% VMT - VMT contour (m-by-n)
% VHT - VHT contour (m-by-n)
% FFV - free flow speed vector (m-by-1)

[m, n] = size(VMT);

FFV = repmat(FFV, 1, n);

DLY = max(zeros(m, n), (VHT - (VMT ./FFV)));
DLY(isnan(DLY)) = 0;

return;
