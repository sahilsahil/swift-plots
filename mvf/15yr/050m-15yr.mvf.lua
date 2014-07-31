-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("15yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 50

-- list of laser thrust forces to run (N)
inputs.forces = {0, 0.004, 0.008, 0.015, 0.025, 0.04}
