-- *.mvt.lua
-- inputs to generate graph of miss distance vs. laser active time

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("15yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- force to use (N)
inputs.force = 2

-- list of times for laser to run (years)
inputs.times = {0.5, 3, 5, 7.5, 10, 12.5, 15, 20}
