-- ivp.lua
-- solve a second order initial value problem with RK4

ivp = {}
ivp.__index = ivp

-- create initial value problem
function ivp.create (accel_func, pos_0, vel_0, t_0, t_step)
	local new_ivp = {}
	setmetatable(new_ivp, ivp)
	
	-- initialize
	new_ivp.accel = accel_func
	new_ivp.pos = pos_0
	new_ivp.vel = vel_0
	new_ivp.time = t_0
	new_ivp.t_step = t_step
	
	return new_ivp
end

-- do single step of classic 4th order Runge-Kutta method
function ivp:step ()
	
	-- sample acceleration at selected four points
	local a1_x, a1_y, a1_z =
		self.accel (self.pos[1], self.pos[2], self.pos[3],
					self.vel[1], self.vel[2], self.vel[3],
					self.time)
	local v1_x, v1_y, v1_z =
		a1_x * self.t_step, a1_y * self.t_step, a1_z * self.t_step
	local r1_x, r1_y, r1_z =
		self.vel[1] * self.t_step,
		self.vel[2] * self.t_step,
		self.vel[3] * self.t_step
	
	local a2_x, a2_y, a2_z =
		self.accel (self.pos[1] + 0.5 * r1_x,
					self.pos[2] + 0.5 * r1_y,
					self.pos[3] + 0.5 * r1_z,
					self.vel[1] + 0.5 * v1_x,
					self.vel[2] + 0.5 * v1_y,
					self.vel[3] + 0.5 * v1_z,
					self.time + 0.5 * self.t_step)
	local v2_x, v2_y, v2_z =
		a2_x * self.t_step, a2_y * self.t_step, a2_z * self.t_step
	local r2_x, r2_y, r2_z =
		(self.vel[1] + 0.5 * v1_x) * self.t_step,
		(self.vel[2] + 0.5 * v1_y) * self.t_step,
		(self.vel[3] + 0.5 * v1_z) * self.t_step
	
	local a3_x, a3_y, a3_z =
		self.accel (self.pos[1] + 0.5 * r2_x,
					self.pos[2] + 0.5 * r2_y,
					self.pos[3] + 0.5 * r2_z,
					self.vel[1] + 0.5 * v2_x,
					self.vel[2] + 0.5 * v2_y,
					self.vel[3] + 0.5 * v2_z,
					self.time + 0.5 * self.t_step)
	local v3_x, v3_y, v3_z =
		a3_x * self.t_step, a3_y * self.t_step, a3_z * self.t_step
	local r3_x, r3_y, r3_z =
		(self.vel[1] + 0.5 * v2_x) * self.t_step,
		(self.vel[2] + 0.5 * v2_y) * self.t_step,
		(self.vel[3] + 0.5 * v2_z) * self.t_step
	
	local a4_x, a4_y, a4_z =
		self.accel (self.pos[1] + r3_x, self.pos[2] + r3_y, self.pos[3] + r3_z,
					self.vel[1] + v3_x, self.vel[2] + v3_y, self.vel[3] + v3_z,
					self.time + self.t_step)
	local v4_x, v4_y, v4_z =
		a4_x * self.t_step, a4_y * self.t_step, a4_z * self.t_step
	local r4_x, r4_y, r4_z =
		(self.vel[1] + 0.5 * v2_x) * self.t_step,
		(self.vel[2] + 0.5 * v2_y) * self.t_step,
		(self.vel[3] + 0.5 * v2_z) * self.t_step
	
	-- apply step to state vector
	self.vel[1], self.vel[2], self.vel[3] =
		self.vel[1] + 1/6 * (v1_x + 2 * (v2_x + v3_x) + v4_x),
		self.vel[2] + 1/6 * (v1_y + 2 * (v2_y + v3_y) + v4_y),
		self.vel[3] + 1/6 * (v1_z + 2 * (v2_z + v3_z) + v4_z)
		
	self.pos[1], self.pos[2], self.pos[3] =
		self.pos[1] + 1/6 * (r1_x + 2 * (r2_x + r3_x) + r4_x),
		self.pos[2] + 1/6 * (r1_y + 2 * (r2_y + r3_y) + r4_y),
		self.pos[3] + 1/6 * (r1_z + 2 * (r2_z + r3_z) + r4_z)
	
	self.time = self.time + self.t_step
end

-- do single step with Verlet
function ivp:verlet()
	
	if not self.accel_x0 then
		
		self.accel_x0, self.accel_y0, self.accel_z0 =
			self.accel (self.pos[1], self.pos[2], self.pos[3],
				self.vel[1], self.vel[2], self.vel[3],
				self.time)
	
	end
	
	self.pos[1], self.pos[2], self.pos[3] =
		self.pos[1] + self.t_step * (self.vel[1] + 0.5 * self.accel_x0 * self.t_step),
		self.pos[2] + self.t_step * (self.vel[2] + 0.5 * self.accel_y0 * self.t_step),
		self.pos[3] + self.t_step * (self.vel[3] + 0.5 * self.accel_z0 * self.t_step)
	
	self.vel[1], self.vel[2], self.vel[3] =
		self.vel[1] + self.t_step * self.accel_x0,
		self.vel[2] + self.t_step * self.accel_y0,
		self.vel[3] + self.t_step * self.accel_z0
	
	self.time = self.time + self.t_step
	
	local a_x, a_y, a_z =
		self.accel (self.pos[1], self.pos[2], self.pos[3],
			self.vel[1], self.vel[2], self.vel[3],
			self.time)
			
	self.vel[1], self.vel[2], self.vel[3] =
		self.vel[1] + 0.5 * (a_x - self.accel_x0),
		self.vel[2] + 0.5 * (a_y - self.accel_y0),
		self.vel[3] + 0.5 * (a_z - self.accel_z0)
	
	self.accel_x0, self.accel_y0, self.accel_z0 = a_x, a_y, a_z

end

return ivp
