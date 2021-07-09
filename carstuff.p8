pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
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
__gfx__
0000000008666680555555553333333357555555555aa55555555575555555553333333356556655575555550000000000000000555555750000000000000000
0000000007dddd70555555553333333357555555555aa55555555575555555553333333356556655575555550000000000000000555555750000000000000000
000000000d7777d05555555533333333575555555555555555555575555755553333333356656665575555550000000000000000555555750000000000000000
000000000d7777d0aa5555aa33333333575555555555555555555575555755553333333356655655557555550000000000000000555557550000000000000000
0000000007dddd70aa5555aa3333333357555555555555555555557555575555333bb33366655655557555550000000000000000555557550000000000000000
0000000007dddd7055555555333333335755555555555555555555755557555533bbbb3366556665555755550000000000000000555575550000000000000000
0000000007555570555555553333333357555555555aa55555555575555555553bbbbbb366555665555755550000000000000000555575550000000000000000
000000000a5555a0555555553333333357555555555aa5555555557555555555bbbbbbbb66656655555575550000000000000000555755550000000000000000
00000000000000000000000033333b3355555555555555555557555555555555bbbbbbbb66556665555575555555555555555555555755550000000000000000
000000000000000000000000333333b375555555555555555557555555555555bb4444bb66556665555557555555555555555555557555550000000000000000
00000000000000000000000033b333b3575555555555555555575555555575553bb44bb355566655555555755555555555555555575555550000000000000000
000000000000000000000000333b3333555555555555555555555555555575553334433355566554555555577555555555555557755555550000000000000000
000000000000000000000000b33b3b33555777555577775555557555555575553334433356665554555555555775555555555775555555550000000000000000
0000000000000000000000003b3333b3555555555555555555555755555575553334433366655544555555555557755555577555555555550000000000000000
0000000000000000000000003b3333b3555555555555555555555555555555553344443366655544555555555555577777755555555555550000000000000000
00000000000000000000000033333333555555555555555555555555555555553444444355555444555555555555555555555555555555550000000000000000
00000000000000000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000555555555555555577777777555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000555555555577775555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000777777775555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000555555555555555555555555555555550000000000000000000000000000000000000000000000000000000000000000
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
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040506030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000