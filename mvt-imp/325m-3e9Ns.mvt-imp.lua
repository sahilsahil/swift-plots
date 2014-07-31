-- *.imp.lua
-- inputs to generate graph of miss distance vs. impulse time

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("15yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- impulse to apply (N s)
inputs.impulse = 3e9

-- list of times for impulse to occur before impact (years)
inputs.times = {0.1, 1, 3, 5, 7.5, 10, 12.5, 15, 17.5, 20, 22.5, 25, 27.5, 30, 32, 32.5, 35, 37, 37.5, 38, 40, 42.5, 45}
