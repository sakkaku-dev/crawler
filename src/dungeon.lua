local Node = require 'lib.node'
local Room = require 'src.room'
local Dungeon = Node:extend()

local move_dirs = { Vector.UP, Vector.DOWN, Vector.LEFT, Vector.RIGHT }

local function _randomStart(x, y)
	return Vector(math.random(1, x), math.random(1, y))
end

local function _setupMap(w, h)
	local map = {}
	for x = 1, w do
		map[x] = {}

		for y = 1, h do
			map[x][y] = nil
		end
	end
	return map
end

function Dungeon:new(w, h, player)
	self.onNewRoom = Signal()
	self.onRoomEnter = Signal()
	self.onMove = Signal()

	self.map = _setupMap(w, h)
	self.pos = _randomStart(w, h)
	self.size = Vector(w, h)

	player.onMove:register(function(dir) self:move(dir) end)
end

function Dungeon:getSize()
	return self.size
end

function Dungeon:getRotation()
	return self.rotation
end

function Dungeon:move(dir)
	local curr_room = self:activeRoom()

	if curr_room == nil or curr_room:canMove(dir) then
		local new_pos = self.pos + dir
		if self:_isInside(new_pos) then
			self.pos = new_pos
			self.onMove:emit(dir)

			local room = self:activeRoom()
			if room == nil then
				self:_generateRoom(-dir)
				self.onNewRoom:emit(self:activeRoom())
			else
				self.onRoomEnter:emit(room)
			end
		end
	end
end

function Dungeon:activeRoom()
	return self:_getRoom(self.pos)
end

function Dungeon:getRoomInDir(dir)
	return self:_getRoom(self.pos + dir)
end

function Dungeon:_getRoom(pos)
	return self.map[pos.x][pos.y]
end

function Dungeon:_generateRoom(initial_dir)
	local possible, initial = self:_calcDirections(initial_dir)
	local doors = initial

	for _ = 1, math.random(2) do
		local idx = math.random(#possible)
		local dir = table.remove(possible, idx)
		table.insert(doors, dir)
	end


	self.map[self.pos.x][self.pos.y] = Room(self.pos, doors)
end

function Dungeon:_calcDirections(init_dir)
	local result = {}
	local initial = {}

	if not (init_dir == Vector.ZERO) then
		table.insert(initial, init_dir)
	end

	for _, dir in ipairs(move_dirs) do
		local neighbor = self.pos + dir
		if self:_isInside(neighbor) and not (dir == init_dir) then
			local room = self:_getRoom(neighbor)

			if room == nil then
				table.insert(result, dir)
			elseif room:canMove(-dir) then
				table.insert(initial, dir)
			end
		end
	end

	return result, initial
end

function Dungeon:_isInside(pos)
	return pos.x >= 1 and pos.x <= self.size.x
		and pos.y >= 1 and pos.y <= self.size.y
end

function Dungeon:draw()
	self:activeRoom():draw()
end

function Dungeon:getMap()
	return self.map
end

function Dungeon:getDiscoveredPercentage()
	local discovered = 0
	local total = self.size:area()

	for _, row in pairs(self.map) do
		for _, room in pairs(row) do
			if room ~= nil then
				discovered = discovered + 1
			end
		end
	end

	return discovered / total
end

return Dungeon
