function [GP_V, GP_F, GP_D, HOV_V, HOV_F, HOV_D, ORD, ORF, FRD, FRF, ORQ] = extract_simulation_data(ptr,data_file,range)

% Extracting link data
link_id = xlsread(data_file, 'GP_Speed', sprintf('a%d:f%d', range(1), range(2)));
gp_id = link_id(:, 1)'; % GP link IDs
pm = link_id(:, 2)'; % postmiles
llen = link_id(:, 3)'; % link lengths in miles
ffspeeds = link_id(:, 5)'; % free flow speeds
gp_cap = xlsread(data_file, 'GP_Flow', sprintf('e%d:e%d', range(1), range(2)));
gp_cap = gp_cap';
link_id = xlsread(data_file, 'HOV_Flow', sprintf('a%d:e%d', range(1), range(2)));
hov_id = link_id(:, 1)'; % HOV link IDs
hov_cap = link_id(:, 5)'; % HOV link capacities

gp_cd = round(gp_cap ./ ffspeeds);
hov_cd = round(hov_cap ./ ffspeeds);


or_id = xlsread(data_file, 'On-Ramp_Demand', sprintf('g%d:g%d', range(1), range(2)));
or_id = or_id';
ORD = xlsread(data_file, 'On-Ramp_Demand', sprintf('k%d:kl%d', range(1), range(2)));
ORK = xlsread(data_file, 'On-Ramp_Knobs', sprintf('k%d:kl%d', range(1), range(2)));
ORD = ORD .* ORK;
has_or = find(max(ORD,[],2)>0);
has_or = has_or';


fr_id = xlsread(data_file, 'Off-Ramp_Demand', sprintf('g%d:g%d', range(1), range(2)));
fr_id = fr_id';
FRD = xlsread(data_file, 'Off-Ramp_Demand', sprintf('k%d:kl%d', range(1), range(2)));
FRK = xlsread(data_file, 'Off-Ramp_Knobs', sprintf('k%d:kl%d', range(1), range(2)));
FRD = FRD .* FRK;
has_fr = find(max(FRD,[],2)>0);
has_fr = has_fr';


link_id = ptr.scenario_ptr.link_id_begin_end(:, 1)';

% initialization
m = size(gp_id, 2);
GP_V = zeros(m, 288);
GP_F = zeros(m, 288);
GP_D = zeros(m, 288);
HOV_V = zeros(m, 288);
HOV_F = zeros(m, 288);
HOV_D = zeros(m, 288);


% data extraction
fprintf('Extracting simulation data - speeds and flows...\n');
for i = 1:m
  idx = find(link_id == gp_id(i));
  %den = ptr.density_veh{1}(2:289, idx) + ptr.density_veh{2}(2:289, idx);
  den = ptr.density_veh{1}(2:289, idx);
  den = den' ./ (llen(i)*ones(1, 288));
  %outflow = ptr.outflow_veh{1}(:, idx) + ptr.outflow_veh{2}(:, idx);
  outflow = ptr.outflow_veh{1}(:, idx);
  outflow = 12*outflow';
  V = outflow ./ den;
  V = max([V; zeros(1, 288)]);
  V = min([V; ffspeeds(i)*ones(1, 288)]);
  GP_V(i, :) = V;
  GP_D(i, :) = den;
  %inflow = ptr.inflow_veh{1}(:, idx) + ptr.inflow_veh{2}(:, idx);
  inflow = ptr.inflow_veh{1}(:, idx);
  inflow = 12*inflow';
  %inflow = min([inflow; gp_cap(i)*ones(1, 288)]);
  GP_F(i, :) = inflow;

  if hov_id(i) ~= 0
    idx = find(link_id == hov_id(i));
    den = ptr.density_veh{1}(2:289, idx) + ptr.density_veh{2}(2:289, idx);
    den = den' ./ (llen(i)*ones(1, 288));
    outflow = ptr.outflow_veh{1}(:, idx) + ptr.outflow_veh{2}(:, idx);
    outflow = 12*outflow';
    V = outflow ./ den;
    V = max([V; zeros(1, 288)]);
    V = min([V; ffspeeds(i)*ones(1, 288)]);
    HOV_V(i, :) = V;
    HOV_D(i, :) = den;
    inflow = ptr.inflow_veh{1}(:, idx) + ptr.inflow_veh{2}(:, idx);
    inflow = 12*inflow';
    %inflow = min([inflow; hov_cap(i)*ones(1, 288)]);
    HOV_F(i, :) = inflow;
  end
end

GP_V = round(GP_V);
GP_F = round(GP_F);
GP_D = round(GP_D);
HOV_V = round(HOV_V);
HOV_F = round(HOV_F);
HOV_D = round(HOV_D);

%%% HACK begin %%%
for i = 1:m
  for j = 1:288
    if GP_D(i, j) < 1
      GP_V(i, j) = ffspeeds(i);
    end
    if hov_id(i) ~= 0
      if HOV_D(i, j) < 1
        HOV_V(i, j) = ffspeeds(i);
      end
      if (HOV_D(i, j) < hov_cd(i)) && (HOV_D(i+1, j) < hov_cd(i+1))
        HOV_V(i, j) = ffspeeds(i);
      end
    end
  end
end
%%% HACK end %%%


GP_V(1, :) = zeros(1, 288);
GP_F(1, :) = zeros(1, 288);

fprintf('Extracting simulation data - ramp flows...\n');
m = size(has_or, 2);
ORF = ORD;
ORQ = ORD;
for i = 1:m
  idx = find(link_id == or_id(has_or(i)));
  %outflow = ptr.outflow_veh{1}(:, idx) + ptr.outflow_veh{2}(:, idx);
  outflow = ptr.outflow_veh{1}(:, idx);
  outflow = 12*outflow';
  ORF(has_or(i), :) = round(outflow);
  den = ptr.density_veh{1}(2:289, idx);
  ORQ(has_or(i), :) = round(den');
end

m = size(has_fr, 2);
FRF = FRD;
for i = 1:m
  idx = find(link_id == fr_id(has_fr(i)));
  %inflow = ptr.inflow_veh{1}(:, idx) + ptr.inflow_veh{2}(:, idx);
  inflow = ptr.inflow_veh{1}(:, idx);
  inflow = 12*inflow';
  FRF(has_fr(i), :) = round(inflow);
end

%ORQ = compute_or_queues(ORD-ORF);
%ORF = round(ORF);
%FRF = round(FRF);


% write data to spreadsheet
if 1
fprintf('Writing data to %s...\n', data_file);
xlswrite(data_file, GP_V, 'GP_Speed', sprintf('i%d:kj%d', range(1), range(2)))
xlswrite(data_file, GP_F, 'GP_Flow', sprintf('i%d:kj%d', range(1), range(2)))
xlswrite(data_file, GP_D, 'GP_Density', sprintf('i%d:kj%d', range(1), range(2)))
xlswrite(data_file, gp_cd', 'GP_Density', sprintf('e%d:e%d', range(1), range(2)))
xlswrite(data_file, HOV_V, 'HOV_Speed', sprintf('i%d:kj%d', range(1), range(2)))
xlswrite(data_file, HOV_F, 'HOV_Flow', sprintf('i%d:kj%d', range(1), range(2)))
xlswrite(data_file, HOV_D, 'HOV_Density', sprintf('i%d:kj%d', range(1), range(2)))
xlswrite(data_file, hov_cd', 'HOV_Density', sprintf('e%d:e%d', range(1), range(2)))
xlswrite(data_file, ORF, 'On-Ramp_Flow', sprintf('k%d:kl%d', range(1), range(2)))
xlswrite(data_file, FRF, 'Off-Ramp_Flow', sprintf('k%d:kl%d', range(1), range(2)))
xlswrite(data_file, ORQ, 'On-Ramp_Queue', sprintf('k%d:kl%d', range(1), range(2)))
end
