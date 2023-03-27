local Button = require 'lib.node.control.button'
local Label = require 'lib.node.control.label'
local ResizeEvent = require 'lib.input.resize-event'
local Container = require 'lib.node.control.container'

local Map = require 'src.map'

local MainContainer = Container:extend()

local textTheme = { color = { 1, 1, 1, 1 } }
local health = Label():setTheme(textTheme)
local inventory = Container(Vector.DOWN):setTheme({ 0, 0.5, 0, 0.5 })
local statusContainer = Container(Vector.DOWN)
	:setTheme({ background = { 0, 0.5, 0, 0.5 } })
	:addChild(health)
	:addChild(inventory)

local actionsContainer = Container(Vector.RIGHT)

local eventText = Label():setTheme(textTheme)
local mainTextContainer = Container(Vector.DOWN)
	:setTheme({ background = { 0.5, 0.5, 0, 0.5 } })
	:addChild(eventText)
	:addChild(actionsContainer)

function MainContainer:new(dungeon, player)
	MainContainer.super.new(self, Vector.RIGHT, Vector.BOT_LEFT)
	self:setTheme({ background = { 0.5, 0, 0, 0.7 } })

	self.onItemPickup = Signal()

	player.onHealthChange:register(function(hp, max_hp)
		health:setText('HP: ' .. hp .. ' / ' .. max_hp)
	end)
	player.onInventoryChange:register(function(items)
		inventory:clearChildren()
		for _, item in ipairs(items) do
			inventory:addChild(Label(item):setTheme(textTheme))
		end
	end)

	self:addChild(
		statusContainer:setMinSize(Unit.w(0.2), Unit.w(0.1)),
		mainTextContainer:setGrow(true),
		Map(dungeon):setMinSize(Unit.w(0.1), Unit.w(0.1))
	)
end

function MainContainer:input(ev)
	if ev:is(ResizeEvent) then
		local x, y = ev:getSize()
		self:setMinSize(Vector(x, 0))
		self:setPosition(Vector(0, y))
	end

	MainContainer.super.input(self, ev)
end

function MainContainer:showNoEvents()
	eventText:setText("")
	actionsContainer:clearChildren()
end

function MainContainer:showEnemyEvent(enemy)
	eventText:setText('You encounter a ' .. enemy .. '. What do you do?')
end

function MainContainer:showLootEvent(loot)
	eventText:setText('You found a ' .. loot .. '.')

	local pickupBtn = Button()
		:addChild(Label('Pickup'):setTheme(textTheme))
		:setTheme({ background = { 1, 1, 0, 0.5 } })
		:setHoverTheme({ background = { 0, 1, 0, 0.5 } })
	pickupBtn.onClick:register(function()
		self.onItemPickup:emit(loot)
		eventText:setText('You picked up a ' .. loot .. '.')
		actionsContainer:clearChildren()
	end)

	actionsContainer:addChild(pickupBtn)
end

return MainContainer
