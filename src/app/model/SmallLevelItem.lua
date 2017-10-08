
local SmallLevelItem = class("SmallLevelItem", function()
	local node = cc.Node:create()
	return node
end)

local offset = 8
local offsetTop = 8

--标记是前景色还是背景色
local State = {
	Behind = 1,
	Front = 2
}

-- 构造函数
function SmallLevelItem:ctor(bigLevel, smallLevel, behindColor, frontColor)
	local visiblesize = cc.Director:getInstance():getVisibleSize()

	self.width = visiblesize.width/4

	self.bigLevel = bigLevel
	self.smallLevel = smallLevel

	self.state = State.Behind

	if not GData.smallLevel[bigLevel][smallLevel] then
		self.state = State.Front
	end

	self.behind = cc.convertColor(behindColor, "4f")
	self.front = cc.convertColor(frontColor, "4f")

	self.behindColor = behindColor
	self.frontColor = frontColor

	self.tag = -1

	self:init()
end

function SmallLevelItem:init()
	local width = self.width
	self.bg = cc.DrawNode:create()
	self.bg:setPosition(cc.p(-width*0.5, -width*0.5))
	self:addChild(self.bg)
	
	local boxWidth = width - offset * 2
    self.box = cc.DrawNode:create()
	self.box:setPosition(cc.p(-boxWidth*0.5, -boxWidth*0.5))
	self:addChild(self.box)
	
	local boxTopWidth = width - (offset + offsetTop) * 2
    self.boxTop = cc.DrawNode:create()
	self.boxTop:setPosition(cc.p(-boxTopWidth*0.5, -boxTopWidth*0.5))
	self:addChild(self.boxTop)

	local fontSize = 60
	self.numLabel = cc.Label:createWithSystemFont(self.smallLevel, "Geneve", fontSize)
    self:addChild(self.numLabel)

    self:setState(self.state)
end

function SmallLevelItem:setTag(tag)
	self.tag = tag
end

function SmallLevelItem:getTag()
	return self.tag
end

function SmallLevelItem:getSmallLevel()
	return self.smallLevel
end

function SmallLevelItem:getSize()
	return cc.size(self.width, self.width)
end

function SmallLevelItem:setBoxVisible(flag)
	self.box:setVisible(flag)
end

function SmallLevelItem:setState(state)
	self.box:setVisible(false)
	self.state = state
	if state == State.Behind then
		self:setNodeColor(self.behind, self.front)
		self.numLabel:setColor(self.frontColor)
	else
		self:setNodeColor(self.front, self.behind)
		self.numLabel:setColor(self.behindColor)
	end
end

function SmallLevelItem:getState()
	return self.state
end

function SmallLevelItem:setNodeColor(behind, front)
	self.bg:clear()
	self.bg:drawSolidRect(cc.p(0, 0), cc.p(self.width, self.width), behind)

	self.box:clear()
	local boxWidth = self.width - offset * 2
	self.box:drawSolidRect(cc.p(0, 0), cc.p(boxWidth, boxWidth), front)

	self.boxTop:clear()
	local boxTopWidth = self.width - (offset + offsetTop) * 2
	self.boxTop:drawSolidRect(cc.p(0, 0), cc.p(boxTopWidth, boxTopWidth), behind)
end

return SmallLevelItem