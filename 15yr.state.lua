-- 15yr.state.lua
-- initial condition state vectors to produce collision

state = {}

-- time properties of this set of state vectors
state.time_f = 15   -- time by which a collision will have occurred (years)
state.t_step = 2e-4 -- time step to use for integration (years)

-- initial state vector of asteroid
state.asteroid = {}
state.asteroid.pos = { -- initial position (au)
	-4.1025619326121404e-01, -- x
	-8.1371475985075781e-01, -- y
	 0.0000000000000000e+00  -- z
}
state.asteroid.vel = { -- initial velocity (au/year)
	 6.6619537594175622e+00, -- v_x
	-2.5576186179447191e+00, -- v_y
	 0.0000000000000000e+00  -- v_z
}

-- initial state vector of Earth
state.earth = {}
state.earth.pos = { -- initial position (au)
	-9.1575117146126284e-01, -- x
	-4.0416714427102818e-01, -- y
	 0.0000000000000000e+00  -- z
}
state.earth.vel = { -- initial velocity (au/year)
	 2.4385256400957949e+00, -- v_x
	-5.7840457743443965e+00, -- v_y
	 0.0000000000000000e+00  -- v_z
}

return state
