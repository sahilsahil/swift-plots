-- *.mvi.lua
-- inputs to generate graph of miss distance vs. impulse

inputs = {}

-- use initial state vectors from separate file
inputs.state = dofile("0.5yr.state.lua")

-- asteroid diameter (m)
inputs.ast_diam = 325

-- list of impulses to apply (N s)
inputs.impulses = {0, 0.3e10, 1e10, 0.2e11, 0.3e11, 0.4e11, 0.6e11, 1e11}
