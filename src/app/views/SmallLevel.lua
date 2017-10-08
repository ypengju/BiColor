
local SmallLevelItem = require "app.model.SmallLevelItem"
local Level = require "app.views.Level"

local ColorData = require "app.data.ColorData"

local visiblesize = cc.Director:getInstance():getVisibleSize()

local SmallLevel = class("Level", function()
	local node = cc.Layer:create()
	return node
end)

-- 构造函数
function SmallLevel:ctor(bigLevel)
	self.bigLevel = bigLevel
	self.curItem = nil
	self.isShowLevel = false
	self:init()
	self:addContent()
	self:addBtn()
end

function SmallLevel:init()
	self:removeChildByName("SmallBackground", true)
	local color = ColorData[self.bigLevel]
	local bgColor = cc.convertColor(color.behind, "4b")
	local bg = cc.LayerColor:create(bgColor)
    bg:setContentSize(visiblesize)
    bg:setIgnoreAnchorPointForPosition(false);
    bg:setPosition(VisibleRect:center())
    bg:setName("SmallBackground")
    self:addChild(bg)
end

function SmallLevel:addContent()
	local color = ColorData[self.bigLevel]
	local width = visiblesize.width/4
	for i=1, 15 do
		self:removeChildByName("SmallItem"..i, true)
		local item = SmallLevelItem.new(self.bigLevel, i, color.behind, color.front)
		item:setTag(i)
		local posx = ((i-1) % 3) * width
		local posy = visiblesize.height - (math.ceil(i/3)) * width
		local pos = cc.pAdd(VisibleRect:center(), cc.p(posx - width, posy-visiblesize.height*0.5-width*0.5))
		item:setPosition(pos)
		item:setName("SmallItem"..i)
		self:addChild(item)
		funcs.addClick(item, handler(self, self.clickCallback))
	end
end

function SmallLevel:addBtn()
	self:removeChildByName("BackBtn", true)
	local backfile = "back_menu.png"
	local back = ccui.Button:create(backfile, "", "")
 	back:addClickEventListener(function(sender)
 		self:getParent():removeSmallLevel()
    end)
    local backpos = cc.pAdd(VisibleRect:leftTop(), cc.p(50, -50))
    back:setPosition(backpos)
    back:setRotation(90)
    back:setScale(0.8)
    back:setName("BackBtn")
	self:addChild(back)
end

function SmallLevel:clickCallback(item)
	if self.isShowLevel then return end
	local smallLevel = item:getSmallLevel()
	item:setBoxVisible(true)
	if self.curItem and self.curItem ~= item then
		self.curItem:setBoxVisible(false)
	end
	self.curItem = item

	local level = Level.new(self.bigLevel, smallLevel)
	level:setName("LevelLayer")
	self:addChild(level, 1000)

	self.isShowLevel = true
end

function SmallLevel:removeLevelLayer()
	self:removeChildByName("LevelLayer", true)
	self.isShowLevel = false
end

function SmallLevel:nextLevel(bigLevel, smallLevel)
	if self.isShowLevel then
		if bigLevel ~= self.bigLevel then
			self.bigLevel = bigLevel
			self:init()
			self:addContent()
			self:addBtn()
		end

		if not tolua.isnull(self.curItem) then
			self.curItem:setBoxVisible(false)
			self.curItem:setState(1)
		end
		
		local item = self:getChildByName("SmallItem"..smallLevel)
		item:setBoxVisible(true)
		self.curItem = item

		self:getParent():nextLevel(bigLevel)	
		UIHelper.write()
	end
end

return SmallLevel