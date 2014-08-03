function [pm] = make_pm(link_lengths, pm)

sz = size(link_lengths, 1);

for i = 1:(sz-1)
  pm = [pm; (pm(i, 1)-link_lengths(i, 1))];
end

return;
