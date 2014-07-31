-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("15yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 20

-- list of laser thrust forces to run (N)
inputs.forces = {0, 0.0001, 0.0002, 0.0004, 0.001, 0.002, 0.003}
