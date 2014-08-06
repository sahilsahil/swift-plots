-- *.mvi.lua
-- inputs to generate graph of miss distance vs. impulse

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("15yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of impulses to apply (N s)
inputs.impulses = {0, 1e7, 2e7, 3e7, 5e7, 7e7, 1e8, 2e8, 3e8, 5e8}
