clear all;

root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
cfg_folder = fullfile(root, 'pq_ctm', 'networks');
shared_folder = fullfile(root, 'pq_ctm', 'shared');
out_prefix = fullfile(root, 'pq_ctm', 'beats_output/gp');
beats_path = fullfile(root, 'beats');
pointq_state_file = fullfile(shared_folder, 'pointq_state.tsv');
ctm_state_file = fullfile(shared_folder, 'ctm_state.tsv');

xml_file = fullfile(cfg_folder, 'scenario_1.xml');
onramp_id = 64;
offramp_id = 45;
offramp_capacity = 1800;  % vph

sim_dt = 5;
out_dt = 300;
num_steps = 17280;
num_steps = 239;
start_time = 0;
end_time = sim_dt * num_steps;;

queue_threshold = 10;


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


for i = 1:num_steps
  fprintf('%d out of 17280...\n', i);
  
  % wait until point-queue state file is generated
  while exist(pointq_state_file) ~= 2 % 2 means file
    ;
  end

  % read point-q state and delete the point-q state file
  pq_data = dlmread(pointq_state_file, '\t');
  delete(pointq_state_file);

  % overwrite CTM state and set boundary conditions
  onramp = scenario.getLinkWithId(onramp_id);
  onramp.set_density_in_veh(0, pq_data(1, 3));
  capacity = offramp_capacity * (pq_data(1, 2) < queue_threshold);
  scenario.set_capacity_for_link_si(offramp_id, 3600, capacity);

  % make 1 CTM step
  scenario.advanceNSeconds(sim_dt, outputwriter);

  % extract CTM data
  onramp = scenario.getLinkWithId(onramp_id);
  onramp_outflow = onramp.getTotalOutflowInVeh(0) / sim_dt;
  offramp = scenario.getLinkWithId(offramp_id);
  offramp_outflow = offramp.getTotalOutflowInVeh(0) / sim_dt;

  % write CTM state
  fprintf('%d\t%f\t%f\n', (i*sim_dt), (0.1*offramp_outflow), (onramp_outflow));
  dlmwrite(ctm_state_file, [(i*sim_dt) (0.1*(offramp_outflow+0.0000001)) (onramp_outflow)], '\t');
end

outputwriter.close();


