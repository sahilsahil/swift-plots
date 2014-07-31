-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("15yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 150

-- list of laser thrust forces to run (N)
inputs.forces = {0, 0.1, 0.2, 0.4, 0.7, 1.2}
