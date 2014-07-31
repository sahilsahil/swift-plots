-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("5yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 50

-- list of laser thrust forces to run (N)
inputs.forces = {0*90000e-4, 0.004*90000e-4, 0.008*90000e-4, 0.015*90000e-4, 0.025*90000e-4, 0.04*90000e-4}
