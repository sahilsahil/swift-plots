-- *.mvf.lua
-- inputs to generate graph of miss distance vs. laser force

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("0.2yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of laser thrust forces to run (N)
inputs.forces = {0*225000, 0.3*225000, 0.5*225000, 0.7*225000, 1*225000, 1.5*225000, 2*225000, 3*225000}
