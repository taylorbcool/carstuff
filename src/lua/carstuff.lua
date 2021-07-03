Actor = {
  coords = {
    x = 0,
    y = 0
  },
  name = '',
  sprite = 0
}

function Actor:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Actor:move(coords)
  self.coords.x = self.coords.x + coords.x
  self.coords.y = self.coords.y + coords.y
end

function Actor:draw()
  --print(self.coords.x..','..self.coords.y, self.coords.x, self.coords.y + 10)
  spr(self.sprite, self.coords.x, self.coords.y)
end

function AddCoords(c1, c2)
  return {
    x = c1.x + c2.x,
    y = c1.y + c2.y
  }
end

function _init()
  -- track all the actors
  actors = {
    Actor:new({
      name = 'Player',
      sprite = 1,
    })
  }
end

function _update()
  local player = actors[1]
  local dir = { x = 0, y = 0}
  if(btn(0)) dir = AddCoords(dir, { x = -1, y = 0})
  if(btn(1)) dir = AddCoords(dir, { x = 1, y = 0})
  if(btn(2)) dir = AddCoords(dir, { x = 0, y = -1})
  if(btn(3)) dir = AddCoords(dir, { x = 0, y = 1})
  player:move(dir)
end

function _draw()
		cls()
	 for k,v in pairs(actors) do
    v:draw()
  end
end