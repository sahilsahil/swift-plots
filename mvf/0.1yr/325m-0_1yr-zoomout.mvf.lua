-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("0.1yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of laser thrust forces to run (N)
inputs.forces = {0*2e8, 0.3*2e8, 0.5*2e8, 0.7*2e8, 1*2e8, 1.5*2e8, 2*2e8, 3*2e8}
