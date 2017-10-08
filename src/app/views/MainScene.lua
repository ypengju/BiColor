
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

-- local BiSprite = require "app.model.BiSprite"
-- local Level = require "app.views.Level"
local BigLevel = require "app.views.BigLevel"

function MainScene:onCreate()

	UIHelper.init(self)
	UIHelper.read()

    local big = BigLevel.new()
    self:addChild(big)
end

return MainScene
