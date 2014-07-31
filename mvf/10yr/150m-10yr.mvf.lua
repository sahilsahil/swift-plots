-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("10yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 150

-- list of laser thrust forces to run (N)
inputs.forces = {0*22500e-4, 0.1*22500e-4, 0.2*22500e-4, 0.4*22500e-4, 0.7*22500e-4, 1.2*22500e-4}
