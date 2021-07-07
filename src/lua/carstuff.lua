actor = {
  coords = {
    x = 15,
    y = 30
  },
  name = '',
  sprite = 0
}

function actor:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function actor:move(coords)
  self.coords.x = self.coords.x + coords.x
  self.coords.y = self.coords.y + coords.y
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
    })
  }
end

function _update()
  local player = actors[1]
  local dir = { x = 0, y = 0}
  if(btn(0)) dir = addcoords(dir, { x = -1, y = 0})
  if(btn(1)) dir = addcoords(dir, { x = 1, y = 0})
  if(btn(2)) dir = addcoords(dir, { x = 0, y = -1})
  if(btn(3)) dir = addcoords(dir, { x = 0, y = 1})
  --print(dir.x..','..dir.y,10,10)
  player:move(dir)
end

function _draw()
		cls()
    drawmap()
	 for k,v in pairs(actors) do
    v:draw()
  end
end