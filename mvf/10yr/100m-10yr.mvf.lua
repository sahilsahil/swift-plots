-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("10yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 100

-- list of laser thrust forces to run (N)
inputs.forces = {0*22500e-4, 0.02*22500e-4, 0.04*22500e-4, 0.1*22500e-4, 0.2*22500e-4, 0.35*22500e-4}

-- time range (years)
inputs.time_0 = 0     -- start time
inputs.time_f = 15.01 -- end time
inputs.t_step = 2e-4  -- time step to use for numerical integration
