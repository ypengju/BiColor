local BiSprite = require "app.model.BiSprite"
local ColorData = require "app.data.ColorData"

local visiblesize = cc.Director:getInstance():getVisibleSize()
local Level = class("Level", function()
	local node = cc.Layer:create()
	return node
end)

-- 构造函数
function Level:ctor(bigLevel, smallLevel)
	self.bigLevel = bigLevel
	self.smallLevel = smallLevel
	self.isTopHide = true
	self.isTopMoving = false

	self:init(bigLevel)
	self:addTopMenu()
	self:addContent(bigLevel, smallLevel)
	self:addListenr()

end

function Level:init(bigLevel)
	local data = ColorData[bigLevel]
	if not data then return end
	local behind = data.behind

	self:removeChildByName("Background", true)
	local bgColor = cc.convertColor(behind, "4b")
	local bg = cc.LayerColor:create(bgColor)
    bg:setContentSize(visiblesize)
    bg:ignoreAnchorPointForPosition(false);
    bg:setPosition(VisibleRect:center())
    bg:setName("Background")
    self:addChild(bg)
end

function Level:restart()
	self:addContent(self.bigLevel, self.smallLevel)
	funcs.clearRecord()
	funcs.clearBackRecord()
end

function Level:nextLevel()
	GData.smallLevel[self.bigLevel][self.smallLevel ] = true
	if self.smallLevel == 15 then
		GData.bigLevel[self.bigLevel] = true
		
		self.bigLevel = self.bigLevel + 1
		self.smallLevel = 1
		self:init(self.bigLevel)
	else
		self.smallLevel = self.smallLevel + 1
	end
	self:restart()
	self:getParent():nextLevel(self.bigLevel, self.smallLevel)
end

function Level:addContent(bigLevel, smallLevel)
	local data = ColorData[bigLevel]
	local behind = data.behind
	local front = data.front

	local datastr = string.format("app.data.Data_%s_%s", bigLevel, smallLevel)
 	local data = require(datastr)

	GData.level = {}

 	local boxSize = 100
 	local offposx = (visiblesize.width - boxSize * 6) / 2
 	local offposy = (visiblesize.height - boxSize * 11) / 2

 	self:removeChildByName("ContentRootNode", true)
 	local rootNode = cc.Node:create()
 	rootNode:setName("ContentRootNode")
 	rootNode:setPositionY(-visiblesize.height)
 	self:addChild(rootNode)

 	for row, rowdata in ipairs(data) do
 		for line, linedata in ipairs(rowdata) do
 			local s = BiSprite.new(boxSize, linedata, behind, front)
			local x = boxSize * line - boxSize * 0.5 + offposx
			local y = visiblesize.height - boxSize * row + boxSize * 0.5 - offposy
			s:setPosition(cc.p(x, y))
			s:setCoordinate(row, line)
			rootNode:addChild(s)
			s:addClick()
			s:setTag(row * 100 + line)

			GData.level[row] = GData.level[row] or {}
			GData.level[row][line] = s
 		end
 	end

 	local mov = cc.MoveBy:create(0.5, cc.p(0,visiblesize.height))
 	local cb = cc.CallFunc:create(function()
 		local label = self:getChildByName("GuildLabel")
 		if not tolua.isnull(label) then
 			label:setVisible(true)
 		end
 	end)
 	local seq = cc.Sequence:create(mov, cb)
 	rootNode:runAction(seq)

 	if bigLevel == 1 and smallLevel < 6 then
		self:showGuild(smallLevel)
	end

 	if not self.isTopHide then
 		self:changeTop()
 	end
end

function Level:removeFromParent()
	local rootNode = self:getChildByName("ContentRootNode")
	local visiblesize = cc.Director:getInstance():getVisibleSize()
	local mov = cc.MoveBy:create(0.5, cc.p(0, -visiblesize.height))
	local cb = cc.CallFunc:create(function()
		self:getParent():removeLevelLayer()
	end)
	local seq = cc.Sequence:create(mov, cb)
	rootNode:stopAllActions()
 	rootNode:runAction(seq)

 	if not self.isTopHide then
 		self:changeTop()
 	end
end

function Level:addTopMenu()
	local topNode = cc.Node:create()
	topNode:setName("TopNode")
	self:addChild(topNode, 1000)

	local backfile = "back_level_sel.png"
	local back = ccui.Button:create(backfile, "", "")
 	back:addClickEventListener(function(sender)
 		if self.isShowSuccess then return end
 		self:removeFromParent()
    end)
    local backpos = cc.pAdd(VisibleRect:leftTop(), cc.p(50, -50))
    back:setPosition(backpos)
    back:setScale(0.8)
	topNode:addChild(back)

	local restartfile = "replay.png"
	local restart = ccui.Button:create(restartfile, "", "")
 	restart:addClickEventListener(function(sender)
 		if self.isShowSuccess then return end

 		self:restart()
    end)
    local restartpos = cc.pAdd(VisibleRect:top(), cc.p(0, -50))
    restart:setPosition(restartpos)
    restart:setScale(0.8)
	topNode:addChild(restart)

	local buyfile = "back_menu.png"
	local buy = ccui.Button:create(buyfile, "", "")
	local buypos = cc.pAdd(VisibleRect:rightTop(), cc.p(-50, -50))
    buy:setPosition(buypos)
    buy:setScale(0.8)
 	buy:addClickEventListener(function(sender)
 		if self.isShowSuccess then return end

 		print("small")
    end)
	topNode:addChild(buy)
	topNode:setPosition(cc.p(0, 100))
end


function Level:changeTop()

	if self.isTopMoving then return end

	local topNode = self:getChildByName("TopNode")
	topNode:stopAllActions()
	local mov = cc.MoveTo:create(0.3, cc.p(0, 0))
	if not self.isTopHide then
		mov = cc.MoveTo:create(0.3, cc.p(0, 100))
	end
	local cb = cc.CallFunc:create(function()
		self.isTopMoving = false
	end)
	local seq = cc.Sequence:create(mov, cb)
	topNode:runAction(seq)
	self.isTopHide = not self.isTopHide
	self.isTopMoving = true
end

function Level:addListenr()
	local startPos = 0
	local isMove = false
    local function onTouchesBegan(touches, event)
    	startPos = touches[1]:getLocation()
    	isMove = false
    	return true
    end

    local function onTouchesMoved(touches, event)
    end

    local function onTouchesEnded(touches, event)
    	local endPos = touches[1]:getLocation()

    	if startPos.x - endPos.x > 30 then
    		local data = funcs.popRecord()
			if data then
				local curNode = data.curNode
				local nextNode = data.nextNode
				funcs.moveDirection(nextNode, curNode, true)
				funcs.pushBackRecord(data)
			end
			isMove = true
	    elseif startPos.x - endPos.x < -30 then
	    	local data = funcs.popBackRecord()
	    	if data then
	    		local curNode = data.curNode
				local nextNode = data.nextNode
				funcs.moveDirection(curNode, nextNode)
				if math.abs(nextNode:getNum()) > 0 then
					nextNode:setNumVisible(true)
				end
				funcs.pushRecord(curNode, nextNode)
	    	end
    		isMove = true
		end

		if not isMove then
	 		if not self.isShowSuccess then
				self:changeTop()
			end
		end
    end

	local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function Level:checkSuccess()
	local isSuc = true
	for row, rowdata in ipairs(GData.level) do
		for line, item in ipairs(rowdata) do
			if not tolua.isnull(item) and (item:getNum() ~= 0 or item:getState() == 2) then
				isSuc = false
			end
		end
	end

	if isSuc then
		self:showSuccess()
	end
end

function Level:showSuccess()
	self:removeChildByName("GuildLabel", true)
	self.isShowSuccess = true
	local success = cc.Sprite:create("clean.png")
	success:setPosition(VisibleRect:center())
	success:setScale(5)
	success:setName("Clean")
	success:setVisible(false)
	self:addChild(success, 9999)
	local del1 = cc.DelayTime:create(0.5)
	local cb1 = cc.CallFunc:create(function()
		local suc = self:getChildByName("Clean")
		suc:setVisible(true)
	end)
	local sca = cc.ScaleTo:create(0.4, 1)
	local del2 = cc.DelayTime:create(0.8)
	local cb = cc.CallFunc:create(function()
		self:removeChildByName("Clean", true)
		self:nextLevel()
		self.isShowSuccess = false
	end)
	local seq = cc.Sequence:create(del1, cb1, sca, del2, cb)
	success:runAction(seq)
end

function Level:showLabel(str)
	local data = ColorData[self.bigLevel]
	local front = data.front
	self:removeChildByName("GuildLabel", true)
	local label = cc.Label:createWithSystemFont(str, "Geneve", 50)
    label:setColor(front)
    local pos = cc.pAdd(VisibleRect:bottom(), cc.p(0, 200))
    label:setPosition(pos)
    label:setName("GuildLabel")
    label:setVisible(false)
    self:addChild(label)
end

function Level:showGuild(level)
	if level == 1 then
		self:showLabel("利用画笔将屏幕涂成主色")
		local item = GData.level[6][2]
		if item then
			item:flashBox()
		end

		for i= 3, 5 do
			local s = GData.level[6][i]
			if s then
				s:showTriangle()
			end
		end
	elseif level == 2 then
		self:showLabel("再来一次")
	elseif level == 3 then
		self:showLabel("有点难度喽：）")
	elseif level == 4 then
		self:showLabel("点击屏幕主色区域显示菜单")
	elseif level == 5 then
		self:showLabel("向左滑动撤销上一步\n向右滑动恢复上一步操作")
	end
end

return Level