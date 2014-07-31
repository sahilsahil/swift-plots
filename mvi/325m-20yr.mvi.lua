-- *.mvi.lua
-- inputs to generate graph of miss distance vs. impulse

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("20yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of impulses to apply (N s)
inputs.impulses = {0, 0.1e9, 0.3e9, 0.6e9, 1e9, 1.5e9, 2e9, 3e9}
