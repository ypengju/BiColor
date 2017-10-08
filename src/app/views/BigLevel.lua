-- local BiSprite = require "app.model.BiSprite"
local BigLevelItem = require "app.model.BigLevelItem"
local SmallLevel = require "app.views.SmallLevel"
local ColorData = require "app.data.ColorData"


local BigLevel = class("Level", function()
	local node = cc.Layer:create()
	return node
end)



-- 构造函数
function BigLevel:ctor()
	self.curLevel = 0
    self.bigItem = {}
	self:init(level)
end

function BigLevel:init()

	local visiblesize = cc.Director:getInstance():getVisibleSize()

	local page=ccui.PageView:create()
    page:setContentSize(visiblesize)
    page:setTouchEnabled(true)
    self:addChild(page)
    self.page = page

    -- local firstPage = self:createFirst()
    -- page:addPage(firstPage)

    for i=1, 4 do
    	local p = self:createPage(i)
    	page:addPage(p)
    end
    page:setCurrentPageIndex(0)

     --注册事件
    page:addEventListener(function(sender,event)
        if event==ccui.PageViewEventType.turning then

        end
    end)
end

function BigLevel:createFirst()
	local visiblesize = cc.Director:getInstance():getVisibleSize()

	local layout = ccui.Layout:create()
    layout:setContentSize(visiblesize)

    local behind = cc.convertColor(cc.c3b(250, 234, 177), "4b")
    local front = cc.convertColor(cc.c3b(238, 126, 123), "4b")

	local bg = cc.LayerColor:create(behind)
    bg:setContentSize(visiblesize)
    bg:ignoreAnchorPointForPosition(false);
    bg:setPosition(VisibleRect:center())
    bg:setName("BigLevelBg")
    layout:addChild(bg)

    local label = cc.Label:createWithTTF("C\tO\tL\tO\tR", "DroidSans.HappyRuika.ttf", 60)
    label:setColor(front)
    label:setPosition(VisibleRect:center())
    layout:addChild(label)

    local btn = cc.Label:createWithSystemFont("点击开始", "Geneve", 30)
    btn:setColor(front)
    local pos = cc.pAdd(VisibleRect:bottom(), cc.p(0, 100))
    btn:setPosition(pos)
    layout:addChild(btn)

    funcs.addClick(bg, function()
        self.page:setCurrentPageIndex(1)
    end)

    return layout
end

function BigLevel:createPage(index)
	local size = cc.Director:getInstance():getVisibleSize()
	local itemWidth = size.width / 4

	local layout=ccui.Layout:create()
    layout:setContentSize(size)

    local begin = 4*(index-1) + 1
    for i = begin, begin+3 do
    	local item = BigLevelItem.new(i)
    	local posx = (i - begin) * itemWidth + itemWidth * 0.5
    	item:setPosition(cc.p(posx, size.height * 0.5))
    	item:setTag(index-1)
    	layout:addChild(item)
    	funcs.addClick(item, handler(self, self.clickCallback))
        table.insert(self.bigItem, item)
    end
    return layout
end

function BigLevel:clickCallback(item)
	local pageIndex = self.page:getCurrentPageIndex()
	if item:getTag() == pageIndex and self.curLevel == 0 then
		local level = item:getLevel()
		if self.curLevel ~= level then

            local isLock = item:getLockState()
            if not isLock then
    			local layer = SmallLevel.new(level)
                layer:setName("SmallLevel")
    			self:addChild(layer)

    			self.curLevel = level

    			self.page:setPosition(cc.p(0, 3000))
            else
                -- print("--is lock")
            end
		end
	end
end

function BigLevel:removeSmallLevel()
    self:removeChildByName("SmallLevel", true)
    self.page:setPosition(cc.p(0, 0))
    self.curLevel = 0
end

function BigLevel:nextLevel(bigLevel)
    local bigItem = self.bigItem[bigLevel]
    if not tolua.isnull(bigItem) then
        bigItem:setState()
    end
end

return BigLevel