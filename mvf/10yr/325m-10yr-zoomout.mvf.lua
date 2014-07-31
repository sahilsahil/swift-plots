-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("10yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of laser thrust forces to run (N)
inputs.forces = {0*22500e-4, 4*22500e-4, 8*22500e-4, 15*22500e-4, 30*22500e-4, 60*22500e-4, 100*22500e-4}
