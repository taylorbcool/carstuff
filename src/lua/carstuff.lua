world_min = {
  x = 0,
  y = 5
}

world_max = {
  x = 127,
  y = 122
}

center = {
  x = 127 /2,
  y = 127 /2
}

level = {
  x = 0,
  y = 0
}

function drawLevel()
  map(level.x, level.y, 0, 0, 128, 32)
end

cam = {
  x = 0, 
  y = 0
}

function drawCam()
  camera(cam.x, cam.y)
end

actor = {
  coords = {
    x = 0,
    y = 0
  },
  name = '',
  sprite = 0, -- changes with powerups?
  velocity = 0,
  acceleration = 0.2, -- changes with powerups
  maxVelocity = 5, -- changes with powerups
  fuel = 50, -- changes with powerups
  steering = 0.25, -- changes with powerups
  braking = 3, -- changes with powerups
}

function actor:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function worldCoordsToCoords(coords)
  return {
    x = coords.x,
    y = coords.y + 5
  }
end

function actor:move(coords)
  self.coords.x = self.coords.x + (coords.x * self.velocity)
  self.coords.y = self.coords.y + (coords.y * self.velocity)
  return {
    x = self.coords.x,
    y = self.coords.y
  }
end


function actor:draw()
  -- print(self.coords.x..','..self.coords.y, self.coords.x, self.coords.y + 10)
  spr(self.sprite, self.coords.x, self.coords.y)
end

function addcoords(c1, c2)
  return {
    x = c1.x + c2.x,
    y = c1.y + c2.y
  }
end

function drawmap()
  map(0, 0, 0, 0, 32, 64)
end

function drawFuel()
  print(actors[1].fuel, 25, 5, 7)
  print("fuel:", 5, 5, 7)
end

function _init()
  -- track all the actors
  actors = {
    actor:new({
      name = 'player',
      sprite = 1,
      coords = center
    })
  }
end

function _update()
  local player = actors[1]
  local dir = { x = 0, y = 0}
  -- steering
  if(btn(0)) then 
    dir = addcoords(dir, { x = -player.steering, y = 0})
  end
  if(btn(1)) then 
    dir = addcoords(dir, { x = player.steering, y = 0})
  end
  -- accelerating
  if(btn(4)) then
    if(player.fuel > 0) then
      dir = addcoords(dir, { x = 0, y = 1})
      player.velocity = player.velocity + player.acceleration
      player.fuel = player.fuel - 1
      if(player.velocity > player.maxVelocity) player.velocity = player.maxVelocity;
    end
  end
  -- braking
  if(btn(5)) then
    if(player.velocity < 0) player.velocity = 0
    player.velocity = player.velocity - player.braking
  end
  -- coasting
    player.velocity = player.velocity - 0.0001
  if(player.velocity < 0) player.velocity = 0
  cam = addcoords(player:move(dir), { x = - 127 /2.0, y = -127 /2.0})
end

function _draw()
		cls()
    drawCam()
    drawLevel()
    drawFuel()
	  for k,v in pairs(actors) do
    v:draw()
  end
end