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
  maxVelocity = 60,
  direction = 90,
  acceleration = 0.2, -- changes with powerups
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
  self.coords.x = self.coords.x + (coords.x * 2 * (self.velocity / self.maxVelocity))
  self.coords.y = self.coords.y + (coords.y * 2 * (self.velocity / self.maxVelocity))
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
  --print(flr(actors[1].fuel), 25, 5, 7)
  print("fuel: "..flr(actors[1].fuel), actors[1].coords.x - 127 / 2 + 5, actors[1].coords.y - 127 / 2 + 5, 7)
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
  currentVelocity = player.velocity
  if(btn(4)) then
    dir = addcoords(dir, { x = 0, y = 1})
    player.velocity = player.velocity + 0.1
    if(player.velocity > player.maxVelocity) player.velocity = player.maxVelocity;
    player.fuel -= 0.4
    if(player.fuel < 0) player.fuel = 0
  else 
    player.velocity = player.velocity - player.velocity * 0.02
    if(player.velocity < 1) player.velocity = 0 
    if(player.velocity < 0) then
      player.velocity = 0
    end

    if(player.velocity > 0) then
      dir = addcoords(dir, {x = 0, y = 1})
      player.fuel -= 0.1
      if(player.fuel < 0) player.fuel = 0
    end


  end
  -- braking
  if(btn(5)) then
    if(player.velocity < 0) player.velocity = 0
    player.velocity = player.velocity - player.braking
  end
  -- coasting
  if(player.fuel <= 0) player.velocity = currentVelocity - currentVelocity * 0.1
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