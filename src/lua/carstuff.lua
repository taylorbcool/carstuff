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

inDialog = false

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
  sprite = 0,
  velocity = 0,
  maxVelocity = 2,
  direction = 90
}

function actor:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

dialog = {
  name = '',
  text = {},
  position = 0,
  complete = true
}

function dialog:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function dialog:load(convo)
  self.name = convo.name
  self.text = convo.text
  self.complete = false
end

function dialog:next()
  self.position += 1
  if(self.position >= #self.text) then 
    self.position = 0
    self.complete = true
  end
end

function dialog:draw()
  if(self.complete == false) drawConvoBox(self.name, self.text[self.position + 1])
end

dsprite = {
  sx = 0,
  sy = 0,
  sh = 8,
  sw = 8,
  dx = 0,
  dy = 0,
  alpha = 0
}

function dsprite:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function dsprite:draw()
  palt(self.alpha, true)
  if(self.alpha != 0) palt(0, false)
  sspr(self.sx, self.sy, self.sw, self.sh, self.dx, self.dy)
  if(self.alpha != 0) then
    palt(self.alpha, false)
    palt(0, true)
  end
end

function drawConvoBox(name, text)
  palt(0, false)
  rectfill(0, 108, 127,127, 0)
  palt(0, true)
  rect(1, 110, 126, 126, 6)
  line(19,110, 51, 110, 0)
  print(name..':', 20, 108, 6)
  print(text, 20, 119, 6)
  zeusSprite:draw()
  chrisSprite:draw()
end

convoA = { 
    name = 'zeus',
    text = {
      "bet you're wondering",
      "why you're here",
      "nerd"
    }
  }


zeusSprite = dsprite:new({
  sx = 24,
  sy = 32,
  sh = 16,
  sw = 16,
  alpha = 0,
  dx = 109,
  dy = 109
})

chrisSprite = dsprite:new({
  sx = 40,
  sy = 32,
  sh = 16,
  sw = 16,
  alpha = 3,
  dx = 4,
  dy = 109
})


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

function _init()
  -- track all the actors
  actors = {
    actor:new({
      name = 'player',
      sprite = 1,
      coords = center
    })
  }

  currentDialog = dialog:new()
  currentDialog:load(convoA)
end

function _update()
  local player = actors[1]
  local dir = { x = 0, y = 0}
  if(btnp(5)) then 
    currentDialog:next()
  end
  if(btn(0)) then 
    dir = addcoords(dir, { x = -1, y = 0})
  end
  if(btn(1)) then 
    dir = addcoords(dir, { x = 1, y = 0})
  end
  if(btn(4)) then
    dir = addcoords(dir, { x = 0, y = 1})
    player.velocity = player.velocity + 0.1
    if(player.velocity > player.maxVelocity) player.velocity = player.maxVelocity;
  else 
    player.velocity = player.velocity - 0.1
    if(player.velocity < 0) player.velocity = 0
  end
  cam = addcoords(player:move(dir), { x = - 127 /2.0, y = -127 /2.0})
end

function _draw()
		cls()
    --drawCam()
    drawLevel()
	  for k,v in pairs(actors) do
    v:draw()
    --drawConvoBox('zeus','be cooler if you did...')
    currentDialog:draw()
  end
end