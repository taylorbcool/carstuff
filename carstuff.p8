pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
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

function dialogState:load(c, nextMode)
  local newConvo = convo:new()
  newConvo:load(c[1])
  self.convos = c
  self.position = 1
  self.currentLine = newConvo
  self.complete = false
  self.nextMode = nextMode or 'GAME'
end

function dialogState:next()
  self.currentLine:next()
  if(self.currentLine.complete) then 
    self.position += 1
    if(self.position > #self.convos) then 
      self.complete = true
      gameState.mode = self.nextMode
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

-- Map

mapState = {
  x = 0,
  y =0
}

function mapState:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function mapState:draw()
  map(self.x, self.y, 0, 0, 32, 128)
end

-- Cam

camState = {
  x = 0,
  y = 0
}

function camState:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function camState:draw()
  camera(self.x, self.y)
end

-- Game Mode - Game State

playerState = {
  name = '',
  x = 0,
  y = 0,
  sprite = 1, -- changes with powerups?
  velocity = 0,
  acceleration = 0.2, -- changes with powerups
  maxVelocity = 5, -- changes with powerups
  fuel = 50, -- changes with powerups
  steering = 0.25, -- changes with powerups
  braking = 3, -- changes with powerups
}

function playerState:move(coords)
  self.x = self.x + (coords.x * self.velocity)
  self.y = self.y + (coords.y * self.velocity)
  return {
    x = self.x,
    y = self.y
  }
end


function playerState:draw()
  spr(self.sprite, self.x, self.y)
end

function playerState:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

gState = {
  player = playerState:new({
    x = 127 / 2,
    y = 127 / 2
  }),
  cam = camState:new({
    x = 0,
    y = 0
  }),
  map = mapState:new({
    x = 0,
    y = 0
  })
}

function gState:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function gState:controller()
  local dir = { x = 0, y = 0}
  
  if(btn(0)) then 
    dir = addcoords(dir, { x = -self.player.steering, y = 0})
  end
  if(btn(1)) then 
    dir = addcoords(dir, { x = self.player.steering, y = 0})
  end
  -- accelerating
  if(btn(4)) then
    if(self.player.fuel > 0) then
      dir = addcoords(dir, { x = 0, y = 1})
      self.player.velocity = self.player.velocity + self.player.acceleration
      self.player.fuel = self.player.fuel - 1
      if(self.player.velocity > self.player.maxVelocity) self.player.velocity = self.player.maxVelocity;
    end
  end
  -- braking
  if(btn(5)) then
    if(self.player.velocity < 0) self.player.velocity = 0
    self.player.velocity = self.player.velocity - self.player.braking
  end
  -- coasting
  self.player.velocity = self.player.velocity - 0.0001
  if(self.player.velocity < 0) self.player.velocity = 0

  self.cam = camState:new(addcoords(self.player:move(dir), { x = - 127 /2.0, y = -127 /2.0}))
end

function gState:drawFuel()
  print('fuel: '..self.player.fuel, self.player.x - 127/2, self.player.y - 127/2, 7)
end

function gState:draw()
  cls()
  self.map:draw()
  self.cam:draw()

  self.player:draw()
  self:drawFuel()
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

function addcoords(c1, c2)
  return {
    x = c1.x + c2.x,
    y = c1.y + c2.y
  }
end



-- Game loop

function _init()
  gameState.dialog = dialogState:new()
  gameState.dialog:load(convoA)
  gameState.game = gState:new()
  gameState.cam = camState:new()
end

function _update()
  --gameState.cam:draw()
  if(gameState.mode == 'TITLE') then
    title.controller()
  elseif(gameState.mode == 'DIALOG') then 
    gameState.dialog:controller()
  elseif(gameState.mode == 'GAME') then
    gameState.game:controller()
  end
end



function _draw()
  if(gameState.mode == 'TITLE') then 
    title:draw()
  end

  if(gameState.mode == 'DIALOG') then
    gameState.dialog:draw()
  end

  if(gameState.mode == 'GAME') then
    gameState.game:draw()
  end

  print(gameState.debug, 10, 10, 14)
end
__gfx__
0000000008666680555555553333333357555555555aa55555555575555555553333333356556655575555550000000000000000555555750000000000000000
0000000007dddd70555555553333333357555555555aa55555555575555555553333333356556655575555550000000000000000555555750000000000000000
000000000d7777d05555555533333333575555555555555555555575555755553333333356656665575555550000000000000000555555750000000000000000
000000000d7777d0aa5555aa33333333575555555555555555555575555755553333333356655655557555550000000000000000555557550000000000000000
0000000007dddd70aa5555aa3333333357555555555555555555557555575555333bb33366655655557555550000000000000000555557550000000000000000
0000000007dddd7055555555333333335755555555555555555555755557555533bbbb3366556665555755550000000000000000555575550000000000000000
0000000007555570555555553333333357555555555aa55555555575555555553bbbbbb366555665555755550000000000000000555575550000000000000000
000000070a5555a0555555553333333357555555555aa5555555557555555555bbbbbbbb66656655555575550000000000000000555755550000000000000000
00000000000000000000000033333b3355555555555555555557555555555555bbbbbbbb66556665555575555555555555555555555755550000000000000000
000000000000000000000000333333b375555555555555555557555555555555bb4444bb66556665555557555555555555555555557555550000000000000000
000e0000000000000000000033b333b3575555555555555555575555555575553bb44bb355566655555555755555555555555555575555550000000000000000
00ee0000000ee00000000000333b3333555555555555555555555555555575553334433355566554555555577555555555555557755555550000000000000000
00e4e004400e4e0000000000b33b3b33555777555577775555557555555575553334433356665554555555555775555555555775555555550000000000000000
00e4456446544e00000000003b3333b3555555555555555555555755555575553334433366655544555555555557755555577555555555550000000000000000
000e55444455e000000000003b3333b3555555555555555555555555555555553344443366655544555555555555577777755555555555550000000000000000
00004544445400000000000033333333555555555555555555555555555555553444444355555444555555555555555555555555555555550000000000000000
00004544445400000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00004544445400000000000000000000555555555555555577777777555555550000000000000000000000000000000000000000000000000000000000000000
00047874478740000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00044444444440000000000000000000555555555577775555555555555555550000000000000000000000000000000000000000000000000000000000000000
000474ffff4740000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00447e5ff5e744000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
000447ffff7440000000000000000000777777775555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00404444444404000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff0000fffff6ff66c1c1cccc00000767767777003344443333333333000000000000000000000000000000000000000000000000000000000000000000000000
f066660ffffff6ff1ccccc1c00007777777677003444444333333333000000000000000000000000000000000000000000000000000000000000000000000000
f055560f6f6f6fffcc1cc1cc00000fffff77667044fffff333333333000000000000000000000000000000000000000000000000000000000000000000000000
f0000060f6fff6ffc1cccc1c00002222222277674f71f71333333333000000000000000000000000000000000000000000000000000000000000000000000000
066660606ffffff6ccccc1cc0000111111122277fffffff333333333000000000000000000000000000000000000000000000000000000000000000000000000
05666050fff6f6ffccc1cccc0000116211627277fff000f333333333000000000000000000000000000000000000000000000000000000000000000000000000
0555600f6ffffff6c11ccc1c0000222f222272773ffffff333333333000000000000000000000000000000000000000000000000000000000000000000000000
f0000ffff6ff6fffccccc1cc00000ffffff7776733ffff3333333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000774777f77673111111333333333000000000000000000000000000000000000000000000000000000000000000000000000
00000f000000000000000000009666eee77fff771111111111133333000000000000000000000000000000000000000000000000000000000000000000000000
0000ff00000000000000000000007777777fff771110111111111553000000000000000000000000000000000000000000000000000000000000000000000000
f11020ff000000000000000000076767677ff1171110001133115553000000000000000000000000000000000000000000000000000000000000000000000000
00122fff000000000000000000076767677f1fff1111100033355533000000000000000000000000000000000000000000000000000000000000000000000000
f110200000000000000000000007676767711fff1011111111f55333000000000000000000000000000000000000000000000000000000000000000000000000
0000f00000000000000000000007676777711fff1000011111ff5333000000000000000000000000000000000000000000000000000000000000000000000000
000ff00000000000000000000007777771111fff1111000033553333000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
30303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
__map__
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303131303130313030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303031303130303030303030303031313030303030303030303030303030303030303030303030303030303030303130303131313130303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303130313030303030303030303030303030303031313030303030303030303030303030303030303030303031303131303030303030303031303030303030303030303030303
0303131313131313131313030303030303030303030303030303030303030303030303030303030303030303030303030303030303031303130303030303030303030303030303030303030303030303030303030303030303030303030303030303030313130303030303030303030303030313030303030303030303030303
0303030303030303030303130303030303030303030303030303030303030303030303030303030303030303030303031313130313030303030303030303030303030303030303030303030303030303130303030303030303030303030303031313130303030303030303030303030303030303130303030303030303030303
0303030303030303030303031303030303030303030303030303030303030303030303030303030303030303131313130303131303030303030303030303030303030303030303030303030303030303031303030303030303030303031313030303030303030303030303030303030303030303130303030303030303030303
0303030303030303030303031303030303030303030303030303030303031313131313131313130303031313031303030303030313030303030303030303030303030303030303030303030303030303030313130303030303030313130303030303030303030303030303030303030303030303031303030303030303030303
0303030303030303030303031303030303030303030303131313130313030303030303030303131313130303130303030303030303130303030303030303030303030303030303030303030303030303030303031303030303031303030303030303030303030303030303030303030303030303131303030303030303030303
0303030303030303030303031303030303030303030313030303030303030303030303030303030303030313030303030303030303030303031313131313030303030303030303030303030303030303030303031303030303130303030303030303030303030303030303030303030303030313130303030303030303030303
0303030303030303030303031303030303030303030313030303030303030303030303030303030303031303030303030303030303030313130303030303131313130303030303030303030303030303030303031303030313030303030303030303030303030303030303030303030313131303030303030303030303030303
0303030303030303030303030303030303030303031303030303030303030303030303030303030303130303030303030303030303030303130303030303030303031313130303030303030303030303030303030303030313030303030303030303030303030303030303130303130303030303030303030303030303030303
0303030303030303030303031303030303030303031303030303030303030303030303030303030303130303030303030303030303030313031303030303030303030303131313030303030303030303030303031303031303030303030303030303030303030303031313030303030303030303030303030303030303030303
0303030303030303030303031303030303030303130303031313131303131313031313030303030313130303030303030303030303030313030303030303030303030303030313130303030303030303030303031303031303030303030303030303130313030313030303030303030303030303030303030303030303030303
0303030303030303030303130303030303030303130303031303030303030303030303131303030313030303030303030303030303031303030313030303030303030303030303031313030303030303030303030303130303030313031303130303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303130303031303030303030303030303030313030313030303030303030303030303031303030303130303030303030303030303030303130303030303030303031303030313030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030313030303031313030303030303030303030303130313030303030303030303030303130303030303130303030303030303030313131313131313131313131303030303130303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303031313030303030303030313030303030313030303030303030303030303131303030303030303030303030303130303030303031303030303030303030303030303030303030303030303030313030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030313030303030313030303030303030303030303130303030303030303030303030303130303030303030303030303030303030303030303030303030303030303130313030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030313030303030303030303030303030303030303130303030303030303030303131303030303030303030303030303130303030303030313030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303031303030303030303130303030303030303030303131303030303030303030303030313030303030303030303130303030303030303030303030303030303030303030313030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303031303030303030303030303130303030303030303130303030303030303030303131303030303030303030303031313030303030303030303031303030303030303030303030303030303030303130313030303030303030303030303030303030303131313131313131303030303030303030303030303030303
0303030313030303030303030303030313030303030303030313030303030303030303030313131303030303030303030303031303030303030303030303030313030303030303030303030303030303030303031303030303030303030303030303030303031313030303030303030313131303030303030303030303030303
0303030303030303030303030303031303030303030303030313030303030303030303030313031303030303030303030303130303030303030303030303030303130303030303030303030303030303030313031303030303030303030303030303030303130303030303030303030303030313030303030303030303030303
0303031303030303030303030303130303030303030303031303030303030303030303031313031303030303030303030313030303030303030303030303030303031313030303030303030303030303030303031303030303030303030303030303030313030303030303030303030303030303130303030303030303030303
0303130303030303030303030303030303030303030303031303030303030303030303031303031303030303030303031303030303030303030303030303030303030303130303030303030303030303031303031303030303030303030303030303031303030303030303030303030303030303031313030303030303030303
0313030303030303030303030303030303030303030313130303030303030303030303130303030313030303030303131303030303030303030303030303030303030303031303030303030303030303130303031303030303030303030303030313030303030303030303030303030303030303030313030303030303030303
1303030303030303030303030303030303030303031313030303030303030303031313030303030313030303131313030303030303030303030303030303030303030303030313131303030303030313130303031303030303030303030303031303030303030303030303030303030303030303030313030303030303030303
1303030303030303030303030303030303030303130303030303030303030313131303030303030313131313130303030303030303030303030303030303030303030303030303030313131313131303030303031303030303030303030303031303030303030303030303030303030303030303031313030303030303030303
1303030303030303030303030303030303030313030303030303030303031313030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303031313130303030303030303130303030303030303030303030303030303030303031303030303030303030303
1303030303030303030303030303030303130303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303031313030303030313030303030303030303030303030303030303030313030303030303030303030303
1303030303030303030303030303030313130303030303030303030303030303030303030303030303030303030303030303030303030313031313131313130303030303030303030303030303030303030303030303030303131313130303030303030303030303030303030303030303031303030303030303030303030303
1303030303030303030303030303031303030303030303030303030303030303030303030303030303030303030303030303030313031303030303030303031303030303030303030303030303030303030303030303030303030303031313031313031303130303130303130303130303030303030303030303030303030303
__sfx__
01180000090700b0700c0700c0700c0700c0700c0700c0700e0700e0700000000000150701507000000130701307000000000000e0700e0700000000000000000000000000000000000000000000000000000000
011800000c4700e4700f470004000f4700f4600e4700c4700a4700a460004000c4700c4600040013470114700f4700e4700f470004000f4700f460114700f4701147011460114701347011470004050040500405
011800000000000000000000855008540085001605016040000001605016040180500000018050000001805016050160400855008540085500000016050160401605016040160501d0501d040000000000000000
011800000000000000000000c5500c540000001a0501a040000001a0501a0401b050000001b050000001b0501a0501a0400c5500c5400c550000001a0501a0401a0501a0401a0502005020040000000000000000
011800000000000000000000f5500f540000001d0501d040000001d0501d0401f050000001f050000001f0501d0501d0400f5500f5400f550000001d0501d0401d0501d0401d0502405024040000000000000000
__music__
00 01020304
