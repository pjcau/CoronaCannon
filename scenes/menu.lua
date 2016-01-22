-- Menu Scene
-- Displays game's name, the cannon and a couple buttons.

local composer = require('composer')
local widget = require('widget')
local controller = require('libs.controller')
local sounds = require('libs.sounds')

local _W, _H = display.actualContentWidth, display.actualContentHeight
local _CX, _CY = display.contentCenterX, display.contentCenterY

local scene = composer.newScene()

-- Settings sidebar
local newSidebar = require('classes.sidebar').newSidebar

function scene:create()
	local group = self.view

	local background = display.newRect(group, _CX, _CY, _W, _H)
	background.fill = {
	    type = 'gradient',
	    color1 = {0.2, 0.45, 0.8},
	    color2 = {0.7, 0.8, 1}
	}

	local tower = display.newImageRect(group, 'images/tower.png', 192, 256)
	tower.anchorY = 1
	tower.x, tower.y = _W * 0.33, _H - 64

	local cannon = display.newImageRect(group, 'images/cannon.png', 128, 64)
	cannon.anchorX = 0.25
	cannon.x, cannon.y = tower.x, tower.y - 256

	-- Rotate cannon indefinitely
	transition.to(cannon, {time = 4000, rotation = -180, iterations = 0, transition = easing.continuousLoop})

	local numTiles = math.ceil(_W / 64 / 2)
	for i = -numTiles, numTiles do
		local tile = display.newImageRect(group, 'images/green_tiles/3.png', 64, 64)
		tile.anchorY = 1
		tile.x, tile.y = _CX + i * 64, _H
	end

	local title = 'CORONA CANNON'
	local j = 1
	for i = -6, 6 do
		local character = display.newGroup()
		group:insert(character)
		local rect = display.newRect(character, 0, 0, 64, 64)
		rect.strokeWidth = 2
		rect:setFillColor(0.2)
		rect:setStrokeColor(0.8)

		local text = display.newText({
			parent = character,
			text = title:sub(j, j),
			x = 0, y = 0,
			font = native.systemFontBold,
			fontSize = 64
		})
		text:setFillColor(0.8, 0.5, 0.2)

		character.x, character.y = _CX + i * 72, 128
		transition.from(character, {time = 500, delay = 100 * j, y = _H + 100, transition = easing.outExpo})
		j = j + 1
	end

	self.playButton = widget.newButton({
		defaultFile = 'images/buttons/play.png',
		overFile = 'images/buttons/play-over.png',
		width = 380, height = 200,
		x = 400 - 190, y = -200 - 100,
		onRelease = function()
			sounds.play('tap')
			composer.gotoScene('scenes.level_select', {time = 500, effect = 'slideLeft'})
		end
	})
	group:insert(self.playButton)

	transition.to(self.playButton, {time = 1200, delay = 500, y = _H - 128 - self.playButton.height / 2, transition = easing.inExpo, onComplete = function(object)
		transition.to(object, {time = 800, x = _W - 64 - self.playButton.width / 2, transition = easing.outExpo})
	end})

	local sidebar = newSidebar({g = group, onHide = function()
		self:setVisualButtons()
	end})

	self.settingsButton = widget.newButton({
		defaultFile = 'images/buttons/settings.png',
		overFile = 'images/buttons/settings-over.png',
		width = 96, height = 105,
		x = 16 + 48, y = _H - 16 - 52,
		onRelease = function()
			sounds.play('tap')
			sidebar:show()
		end
	})
	self.settingsButton.isRound = true
	group:insert(self.settingsButton)

	self:setVisualButtons()
	sounds.playStream('menu_music')
end

function scene:setVisualButtons()
	controller.setVisualButtons({self.playButton, self.settingsButton})
end

-- Android's back button action
function scene:gotoPreviousScene()
	native.showAlert('Corona Cannon', 'Are you sure you want to exit the game?', {'Yes', 'Cancel'}, function(event)
		if event.action == 'clicked' and event.index == 1 then
			native.requestExit()
		end
	end)
end

scene:addEventListener('create')

return scene
