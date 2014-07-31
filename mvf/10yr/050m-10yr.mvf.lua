-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("10yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 50

-- list of laser thrust forces to run (N)
inputs.forces = {0*22500e-4, 0.004*22500e-4, 0.008*22500e-4, 0.015*22500e-4, 0.025*22500e-4, 0.04*22500e-4}
