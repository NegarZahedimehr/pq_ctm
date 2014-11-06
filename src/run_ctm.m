clear all;

root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
cfg_folder = fullfile(root, 'pq_ctm', 'networks');
shared_folder = fullfile(root, 'pq_ctm', 'shared');
out_prefix = fullfile(root, 'pq_ctm', 'beats_output/gp');
beats_path = fullfile(root, 'beats');
pointq_state_file = fullfile(shared_folder, 'pointq_state.tsv');
ctm_state_file = fullfile(shared_folder, 'ctm_state.tsv');

xml_file = fullfile(cfg_folder, '210W_16to24_v5.xml');
xlsx_file = fullfile(cfg_folder, 'I210WB_Data.xlsx');
onramp_id = 64;
offramp_id = 45;
offramp_capacity = 1800;  % vph

range = [2 128];
pm_dir = -1;

sim_dt = 5;
out_dt = 300;
num_steps = 17280;
%num_steps = 239;
start_time = 0;
end_time = sim_dt * num_steps;
warmup_steps = (3600/sim_dt)*16;
%warmup_steps = num_steps;
max_sim_steps = (3600/sim_dt)*20;
%max_sim_steps = num_steps;

queue_threshold = 20;
demand_class_ratio = 0.333; % between 0 and 1: portion of background demand


import_beats_classes(beats_path);

% make scenario object from xml
scenario = edu.berkeley.path.beats.simulator.ObjectFactory.createAndLoadScenario(xml_file);

try
  %scenario.initialize(sim_dt, start_time, end_time, numParticles);
  %scenario.initialize(sim_dt, start_time, end_time, 1);
  scenario.initialize(sim_dt, start_time, end_time, out_dt, 'text', out_prefix, 1, 1);
  outputwriter = scenario.initOutputWriter();
catch javaerror
  error(['Error in initializing the BeATS scenario: ', javaerror.message]);
end

disp('Scenario initialized');
% Warm-up period
for i = 1:warmup_steps
  fprintf('%d out of %d... [Warmup]\n', i, num_steps);
  % make 1 CTM step
  scenario.advanceNSeconds(sim_dt, outputwriter);
end

for i = (warmup_steps+1):max_sim_steps
  fprintf('%d out of %d... [Simulation]\n', i, num_steps);
  
  % wait until point-queue state file is generated
  while exist(pointq_state_file) ~= 2 % 2 means file
    ;
  end

  s = dir(pointq_state_file);
  while s.bytes == 0
    s = dir(pointq_state_file);
  end

  % read point-q state and delete the point-q state file
  pq_data = dlmread(pointq_state_file, '\t');
  delete(pointq_state_file);

  % overwrite CTM state and set boundary conditions
  onramp = scenario.getLinkWithId(onramp_id);
  onramp.set_density_in_veh(0, pq_data(1, 3));
  capacity = offramp_capacity * (pq_data(1, 2) < queue_threshold);
  qs(i - warmup_steps) = pq_data(1, 2);
  tt(i - warmup_steps) = pq_data(1, 1);
  scenario.set_capacity_for_link_si(offramp_id, 3600, capacity);

  % make 1 CTM step
  scenario.advanceNSeconds(sim_dt, outputwriter);

  % extract CTM data
  onramp = scenario.getLinkWithId(onramp_id);
  onramp_outflow = onramp.getTotalOutflowInVeh(0) / sim_dt;
  offramp = scenario.getLinkWithId(offramp_id);
  offramp_outflow = offramp.getTotalOutflowInVeh(0) / sim_dt;

  frf(i - warmup_steps) = 3600*offramp_outflow;
  % write CTM state
  dlmwrite(ctm_state_file, [(i*sim_dt) (demand_class_ratio*offramp_outflow) ((1-demand_class_ratio)*offramp_outflow) (0.1*onramp_outflow)], '\t');
end

% Cool-off period
for i = (max_sim_steps+1):num_steps
  fprintf('%d out of %d... [Cool-off]\n', i, num_steps);
  % make 1 CTM step
  scenario.advanceNSeconds(sim_dt, outputwriter);
end

outputwriter.close();


%fprintf('Loading scenario %s...\n', xml_file);
ptr = BeatsSimulation;
ptr.load_scenario(xml_file);

%fprintf('Loading simulation data...\n');
ptr.load_simulation_output(out_prefix);

if 0
	return;
end

fprintf('Processing simulation results...\n');
[GP_V, GP_F, GP_D, HOV_V, HOV_F, HOV_D, ORD, ORF, FRD, FRF, ORQ] = extract_simulation_data(ptr,xlsx_file,range);

fprintf('Plotting simulation results...\n');
plot_simulation_data;

fprintf('Computing performnce measures...\n');
performance_measures;
