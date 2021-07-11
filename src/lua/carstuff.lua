gameState = {
  mode = 'TITLE',
  debug = ''
}
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

-- Object Declarations

-- Game Modes - Title
title = {

}

function title.draw()
  cls()
  -- draw the title
  local ttl = 'carstuff: the game'
  local ttlc = genCenterStrCoords(ttl, 10)
  print(ttl, ttlc.x, ttlc.y, 2)
  local pr2c = 'press any button to continue...'
  local pr2cc = genCenterStrCoords(pr2c, 127/2)
  print(pr2c, pr2cc.x, pr2cc.y, 6)

  -- draw the prompt
  drawHogFooter(0,122)
end

function title.controller()
  if(btnp() > 0) gameState.mode = 'DIALOG'
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

hogSprite = dsprite:new({
  sx = 2,
  sy = 10,
  sh = 14,
  sw = 12,
  alpha = 0,
  dx = 0,
  dy = 0
})

function drawHogFooter(x,y)
  local txt = 'a hogsquad production'
  local coords = genCenterStrCoords(txt, y);
  print(txt, coords.x, coords.y, 7)
  coords = getStrCenter(txt, coords.x, coords.y)
  hogSprite.dx = coords.x - 8
  hogSprite.dy = coords.y - 16
  hogSprite:draw()
end


-- Game Mode - Dialog

dialogState = {
  position = 0,
  convos = {},
  currentLine = 0,
  complete = true,
  showGame = false,
}

function dialogState:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function dialogState:load(c)
  local newConvo = convo:new()
  newConvo:load(c[1])
  self.convos = c
  self.position = 1
  self.currentLine = newConvo
  self.complete = false
end

function dialogState:next()
  self.currentLine:next()
  if(self.currentLine.complete) then 
    self.position += 1
    if(self.position > #self.convos) then 
      self.complete = true
    else
      self.currentLine:load(self.convos[self.position])
    end
  end
end

function dialogState:draw()
  cls();
  if(self.complete == false) self.currentLine:draw()
end

function dialogState:controller()
  if(btnp(4)) then 
    self:next()
  end
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

-- util functions

function getStrCenter(str, x, y) 
  mid = flr((#str *4) / 2)
  return {
    x = x + mid,
    y = y
  }
end

function genCenterStrCoords(str, y)
  pixLen = #str * 4
  offset = flr((127 - pixLen) / 2)
  return {
    x = offset,
    y = y
  }
end

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





dialog = {
  position = 0,
  convos = {},
  currentLine = 0,
  complete = true
}

function dialog:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function dialog:load(c)
  local newConvo = convo:new()
  newConvo:load(c[1])
  self.convos = c
  self.position = 1
  self.currentLine = newConvo
  self.complete = false
end

function dialog:next()
  self.currentLine:next()
  if(self.currentLine.complete) then 
    self.position += 1
    if(self.position > #self.convos) then 
      self.complete = true
    else
      self.currentLine:load(self.convos[self.position])
    end
  end
end

function dialog:draw()
  if(self.complete == false) self.currentLine:draw()
end
  

convo = {
  name = '',
  text = {},
  position = 0,
  complete = true
}

function convo:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function convo:load(c)
  self.name = c.name
  self.text = c.text
  self.complete = false
end

function convo:next()
  self.position += 1
  if(self.position >= #self.text) then 
    self.position = 0
    self.complete = true
  end
end

function convo:draw()
  if(self.complete == false) drawConvoBox(self.name, self.text[self.position + 1])
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
  { 
    name = 'zeus',
    text = {
      "bet you're wondering",
      "why you're here",
    }
  },
  {
    name = 'bob',
    text = {
      '...'
    }
  },
  {
    name = 'zeus',
    text = {
      '...',
      '...nerd'
    }
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

  currentDialog = dialog:new()
  currentDialog:load(convoA)
  gameState.dialog = dialogState:new()
  gameState.dialog:load(convoA)
end

function _update()
  local player = actors[1]
  local dir = { x = 0, y = 0}
  
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
  if(gameState.mode == 'TITLE') then
    title.controller()
  elseif(gameState.mode == 'DIALOG') then 
    gameState.dialog:controller()
  end
end



function _draw()
  if(gameState.mode == 'TITLE') then 
    title:draw()
  end

  if(gameState.mode == 'DIALOG') then
    gameState.dialog:draw()
  end

  print(gameState.debug, 10, 10, 14)
end