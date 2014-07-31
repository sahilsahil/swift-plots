-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("1yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 20

-- list of laser thrust forces to run (N)
inputs.forces = {0*2250000e-4, 0.0001*2250000e-4, 0.0002*2250000e-4, 0.0004*2250000e-4, 0.001*2250000e-4, 0.002*2250000e-4, 0.003*2250000e-4}
