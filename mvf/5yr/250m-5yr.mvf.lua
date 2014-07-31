-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("5yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 250

-- list of laser thrust forces to run (N)
inputs.forces = {0*90000e-4, 0.4*90000e-4, 0.8*90000e-4, 1.5*90000e-4, 3*90000e-4, 6*90000e-4}
