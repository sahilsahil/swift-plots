-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("0.1yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of laser thrust forces to run (N)
inputs.forces = {0*2250000, 0.3*2250000, 0.5*2250000, 0.7*2250000, 1*2250000, 1.5*2250000, 2*2250000, 3*2250000}
