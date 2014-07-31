-- *.mvt.lua
-- inputs to generate graph of miss distance vs. laser active time

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("15yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 200

-- force to use (N)
inputs.force = 12

-- list of times for laser to run (years)
inputs.times = {1, 1.5, 2, 2.5, 3, 4, 5, 7}
