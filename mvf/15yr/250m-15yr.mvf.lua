-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("15yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 250

-- list of laser thrust forces to run (N)
inputs.forces = {0, 0.4, 0.8, 1.5, 3, 6}
