-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("10yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of laser thrust forces to run (N)
inputs.forces = {0*22500e-4, 0.5*22500e-4, 1*22500e-4, 2*22500e-4, 4*22500e-4, 7*22500e-4, 12*22500e-4}
