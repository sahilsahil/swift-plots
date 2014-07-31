-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("10yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 20

-- list of laser thrust forces to run (N)
inputs.forces = {0*22500e-4, 0.0001*22500e-4, 0.0002*22500e-4, 0.0004*22500e-4, 0.001*22500e-4, 0.002*22500e-4, 0.003*22500e-4}
