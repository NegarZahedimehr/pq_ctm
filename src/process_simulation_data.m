

% Load simulation data
ptr = BeatsSimulation;
ptr.load_scenario(xml_file);
ptr.simulation_done = true;
ptr.load_simulation_output(out_prefix);


