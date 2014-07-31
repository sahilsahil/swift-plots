-- *.mvi.lua
-- inputs to generate graph of miss distance vs. impulse

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("1yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of impulses to apply (N s)
inputs.impulses = {0, 1.5e9, 5e9, 1e10, 1.5e10, 2e10, 3e10, 5e10}
