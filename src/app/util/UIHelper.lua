local UIHelper = {}

local visiblesize = cc.Director:getInstance():getVisibleSize()
local ActionTime = 0.3

function UIHelper.init(scene)
	UIHelper.mainscene = scene
end


function UIHelper.read()
	local ud = cc.UserDefault:getInstance()
	GData.smallLevel = {}
	for i=1, 16 do
		local bigStr = string.format("BigLevel_%s",i)
		GData.bigLevel[i] = ud:getBoolForKey(bigStr, false)		
		GData.smallLevel[i] = GData.smallLevel[i] or {}
		for j=1, 15 do
			local levelStr = string.format("Level_%s_%s", i, j)
			GData.smallLevel[i][j] = ud:getBoolForKey(levelStr, false)
		end
	end

	if not GData.bigLevel[1] then
		GData.bigLevel[1] = true
	end
end

function UIHelper.write()
	local ud = cc.UserDefault:getInstance()
	for i=1, 16 do
		local bigStr = string.format("BigLevel_%s",i)
		ud:setBoolForKey(bigStr, GData.bigLevel[i])
		GData.smallLevel[i] = GData.smallLevel[i] or {}
		for j=1, 15 do
			local levelStr = string.format("Level_%s_%s", i, j)
			ud:setBoolForKey(levelStr, GData.smallLevel[i][j])
		end
	end
end

function UIHelper.addShield(subLayer)
	local shield = require("app.views.ShieldLayer").new()
	shield:addChild(subLayer)
	return shield
end

function UIHelper.addSmall(level)
	local smallLevel = require("app.views.SmallLevel").new(level)
	smallLevel:setPositionY(-visiblesize.height)
	smallLevel:setName("SmallLevel")
	UIHelper.mainscene:addChild(smallLevel)
	UIHelper.upAction(smallLevel)
end

function UIHelper.removeSmall()
	local shieldLayer = UIHelper.mainscene:getChildByName("SmallLevel")
	UIHelper.downAction(shieldLayer, function()
		shieldLayer:removeFromParent()
	end)
end

function UIHelper.addLevel(bigLevel, smallLevel)
	local shieldLayer = UIHelper.mainscene:getChildByName("SmallLevel")
	UIHelper.upAction(shieldLayer, function()
		local level = require("app.views.Level").new(bigLevel, smallLevel)
		level:setName("Level")
		UIHelper.mainscene:addChild(level)
	end)
end

function UIHelper.removeLevel()
	local levelLayer = UIHelper.mainscene:getChildByName("Level")
	UIHelper.downAction(levelLayer, function()
		local smallLayer = UIHelper.mainscene:getChildByName("SmallLevel")
		UIHelper.downAction(smallLayer, function()
			UIHelper.mainscene:removeChildByName("Level", true)
		end)
	end)
end

function UIHelper.upAction(layer, callback)
	local mov = cc.MoveBy:create(ActionTime,cc.p(0, visiblesize.height))
	local cb = cc.CallFunc:create(function()
		if callback then
			callback()
		end
	end)
	local seq = cc.Sequence:create(mov, cb)
	layer:stopAllActions()
	layer:runAction(seq)
end

function UIHelper.downAction(layer, callback)
	local mov = cc.MoveBy:create(ActionTime, cc.p(0, -visiblesize.height))
	local cb = cc.CallFunc:create(function()
		if callback then
			callback()
		end
	end)
	local seq = cc.Sequence:create(mov, cb)
	layer:stopAllActions()
	layer:runAction(seq)
end

return UIHelper

