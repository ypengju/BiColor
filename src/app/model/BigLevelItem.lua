
local ColorData = require "app.data.ColorData"

local BigLevelItem = class("BigLevelItem", function()
	local node = cc.Node:create()
	return node
end)

-- 构造函数
function BigLevelItem:ctor(bigLevel)
	self.bigLevel = bigLevel
	self.isLock = false
	self:init()
	self:setState()
end

function BigLevelItem:init()
	local color = ColorData[self.bigLevel]
	local behind = cc.convertColor(color.behind, "4f")
	local front = cc.convertColor(color.front, "4f")

	local visiblesize = cc.Director:getInstance():getVisibleSize()
	self.bg = cc.DrawNode:create()
	self.bg:drawSolidRect(cc.p(0, 0), cc.p(visiblesize.width/4, visiblesize.height), behind)
	self.bg:setPosition(cc.p(-visiblesize.width/4*0.5, -visiblesize.height*0.5))
	self:addChild(self.bg)
end

function BigLevelItem:getLevel()
	return self.bigLevel
end

function BigLevelItem:setState()
	self:removeChildByName("BigState", true)
	if not GData.bigLevel[self.bigLevel] then
		local lock = cc.Sprite:create("lock.png")
		lock:setName("BigState")
		lock:setScale(0.6)
		self:addChild(lock)
		self.isLock = true
	else
		self.isLock = false
		local smallLevel = 0
		for i=1, 15 do
			if not GData.smallLevel[self.bigLevel][i] then
				smallLevel = i
				break
			end
		end

		if smallLevel == 0 then
			local succ = cc.Sprite:create("clean.png")
			succ:setName("BigState")
			succ:setScale(0.6)
			self:addChild(succ)
		else
			local color = ColorData[self.bigLevel]
			local label = cc.Label:createWithTTF(smallLevel, "DroidSans.HappyRuika.ttf", 60)
		    label:setColor(color.front)
		    label:setName("BigState")
		    self:addChild(label)
		end
	end
end




function BigLevelItem:getLockState()
	return self.isLock
end

function BigLevelItem:getSize()
	local visiblesize = cc.Director:getInstance():getVisibleSize()
	return cc.size(visiblesize.width/4, visiblesize.height)
end

return BigLevelItem