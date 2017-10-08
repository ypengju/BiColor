
local BiSprite = class("BiSprite", function()
	local node = cc.Node:create()
	return node
end)

local offset = 3
local offsetTop = 3

--标记是前景色还是背景色
local State = {
	Behind = 1,
	Front = 2
}

local Direction = {
	Left  = 1,
	Right = 2,
	Up    = 3,
	Down  = 4
}

-- 构造函数
function BiSprite:ctor(width, num, behindColor, frontColor)
	self.width = width

	local disnum = num
	if num == 'a' then
		disnum = 0
	end
	self.num = tonumber(disnum)

	self.state = State.Behind
	if self.num > 0 or num == 'a' then
		self.state = State.Front
	end

	self.behind = cc.convertColor(behindColor, "4f")
	self.front = cc.convertColor(frontColor, "4f")

	self.behindColor = behindColor
	self.frontColor = frontColor


	self.row = 0
	self.line = 0

	self.tag = -1

	self:init(width)
end

function BiSprite:init(width)

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

	local fontSize = 50
	self.numLabel = cc.Label:createWithSystemFont(self.num, "Geneve", fontSize)
    self:addChild(self.numLabel)

    self:setState(self.state)

    self:setNum(self.num)
end

function BiSprite:setTag(tag)
	self.tag = tag
end

function BiSprite:getTag()
	return self.tag
end

function BiSprite:setNum(num)
	self.num = num
	self.numLabel:setString(math.abs(num))
	if math.abs(num) > 0 then
		if num > 0 then
			self.numLabel:setVisible(true)
			self.numLabel:setColor(self.behindColor)	
		else
			self.numLabel:setVisible(true)
			self.numLabel:setColor(self.frontColor)
		end
	else
		--0显示
		self.numLabel:setVisible(false)
	end
end

function BiSprite:setNumVisible(flag)
	self.numLabel:setVisible(flag)
end

function BiSprite:setState(state)
	self.box:setVisible(false)
	self.state = state
	if state == State.Behind then
		self:setNodeColor(self.behind, self.front)
	else
		self:setNodeColor(self.front, self.behind)
	end
end

function BiSprite:getState()
	return self.state
end

function BiSprite:setNodeColor(behind, front)
	self.bg:clear()
	self.bg:drawSolidRect(cc.p(0, 0), cc.p(self.width, self.width), behind)

	self.box:clear()
	local boxWidth = self.width - offset * 2
	self.box:drawSolidRect(cc.p(0, 0), cc.p(boxWidth, boxWidth), front)

	self.boxTop:clear()
	local boxTopWidth = self.width - (offset + offsetTop) * 2
	self.boxTop:drawSolidRect(cc.p(0, 0), cc.p(boxTopWidth, boxTopWidth), behind)
end


function BiSprite:setCoordinate(row, line)
	self.row = row
	self.line = line
end

function BiSprite:getCoordinate()
	return self.row, self.line
end

function BiSprite:getNum()
	return self.num
end

function BiSprite:setBoxVisible(flag)
	self.box:setVisible(flag)
end

function BiSprite:flashBox()
	local de = cc.DelayTime:create(0.2)
	local cb = cc.CallFunc:create(function()
		self.box:setVisible(false)
	end)
	local de2 = cc.DelayTime:create(0.2)
	local cb2 = cc.CallFunc:create(function()
		self.box:setVisible(true)
	end)
	local seq = cc.Sequence:create(de, cb, de2, cb2)
	local re = cc.RepeatForever:create(seq)
	self.box:stopAllActions()
	self.box:runAction(re)
end

function BiSprite:stopFlash()
	self.box:stopAllActions()
	self.box:setVisible(false)
end


function BiSprite:showTriangle()
	local pice = self.width/3
	local half = self.width/2

	local filledVertices = { cc.p(pice*2 ,half), cc.p(pice, pice*2), cc.p(pice,pice), cc.p(pice*2 ,half) }
	local triangle = cc.DrawNode:create()
	triangle:drawSolidPoly(filledVertices, 3, self.behind)
	triangle:setPosition(cc.p(-self.width*0.5, -self.width*0.5))
	self:addChild(triangle)
end

function BiSprite:getWidth()
	return self.width
end


--获取点击node的范围
local function getBoundingBox(node)
	local x, y = node:getPosition()
	local width = node:getWidth()
	local rect = cc.rect(x-width*0.5, y-width*0.5, width, width)
	return rect
end

local function getAngleByPos(p1,p2)  
    local p = {}  
    p.x = p2.x - p1.x  
    p.y = p2.y - p1.y  
             
    local r = math.atan2(p.y,p.x)*180/math.pi
    return r  
end


function BiSprite:addClick()
	self.startPos = cc.p(self:getPositionX(), self:getPositionY())
	local selfnum = self:getNum()
	self.moveNode = nil
	local function onTouchBegan(pTouch, pEvent)
		local target = pEvent:getCurrentTarget()
		local point = pTouch:getLocation()

		self.startPos = cc.p(self:getPositionX(), self:getPositionY())
		selfnum = self:getNum()

		local num = target:getNum()
		if math.abs(num) == 0 then
			return false
		end

		local rect = getBoundingBox(target)
		local flag = cc.rectContainsPoint(rect, point)
		if flag then
			self.moveNode = BiSprite.new(self.width, self.num, self.behindColor, self.frontColor)
			self.moveNode:setNum(self.num)
			self.moveNode:setState(self.state)
			self.moveNode:setCoordinate(self.row, self.line)
			self.moveNode:setBoxVisible(true)
			self.moveNode:setPosition(self.startPos)
			self:getParent():addChild(self.moveNode, 1000)

			self:setNumVisible(false)

			self:stopFlash()
		end
		return flag
	end
	local function onTouchMoved(pTouch, pEvent)
		if not self.moveNode then return end
		local target = self.moveNode
		local point = pTouch:getLocation()

		local maxDis = target:getWidth()
		local dis = cc.pGetDistance(self.startPos, point)
		if dis <= maxDis then
			target:setPosition(point)
		else
			--手指超出圈外
			local x , y
			local angle = getAngleByPos(self.startPos, point)
			if angle >= 0 and angle <= 90 then
				local radian = angle * math.pi / 180
				x = maxDis * math.cos(radian)
				y = maxDis * math.sin(radian)
			elseif angle > 90 and angle <= 180 then
				local radian = (180 - angle) * math.pi / 180
				x = -maxDis * math.cos(radian)
				y = maxDis * math.sin(radian)
			elseif angle > -180 and angle <-90 then
				local radian = (180 + angle) * math.pi / 180
				x = -maxDis * math.cos(radian)
				y = -maxDis * math.sin(radian)
			elseif angle >= -90 and angle < 0 then
				local radian = -angle * math.pi / 180
				x = maxDis * math.cos(radian)
				y = -maxDis * math.sin(radian)
			end
			local pos = cc.pAdd(self.startPos, cc.p(x, y))
			target:setPosition(pos)

			local half = self.width * 0.5
			local row, line = target:getCoordinate()

			local curNode = GData.level[row][line]
			local isMove = false
			if pos.x > self.startPos.x + half then --右
				local nextNode = GData.level[row][line+1]
				local result = funcs.checkMove(curNode, nextNode)
				if result then
					funcs.moveDirection(curNode, nextNode)
					self.startPos = cc.pAdd(self.startPos, cc.p(self.width, 0))
					self.moveNode:setCoordinate(row, line+1)
					funcs.pushRecord(curNode, nextNode)
					isMove = true
				end
			elseif pos.x < self.startPos.x - half then --左
				local nextNode = GData.level[row][line-1]
				local result = funcs.checkMove(curNode, nextNode)
				if result then
					funcs.moveDirection(curNode, nextNode)
					self.startPos = cc.pAdd(self.startPos, cc.p(-self.width, 0))
					self.moveNode:setCoordinate(row, line-1)
					funcs.pushRecord(curNode, nextNode)

					isMove = true
				end
			elseif pos.y > self.startPos.y + half then --上
				local nextNode = GData.level[row-1][line]
				local result = funcs.checkMove(curNode, nextNode)
				if result then
					funcs.moveDirection(curNode, nextNode)
					self.startPos = cc.pAdd(self.startPos, cc.p(0, self.width))
					self.moveNode:setCoordinate(row-1, line)
					funcs.pushRecord(curNode, nextNode)

					isMove = true
				end
			elseif pos.y < self.startPos.y - half then --下
				local nextNode = GData.level[row+1][line]
				local result = funcs.checkMove(curNode, nextNode)
				if result then
					funcs.moveDirection(curNode, nextNode)
					self.startPos = cc.pAdd(self.startPos, cc.p(0, -self.width))
					self.moveNode:setCoordinate(row+1, line)
					funcs.pushRecord(curNode, nextNode)
					isMove = true
				end
			end

			if isMove then
				funcs.clearBackRecord()	
				local moveNum = self.moveNode:getNum()
				if moveNum > 0 then
					moveNum = moveNum - 1
				else
					moveNum = moveNum + 1
				end
				self.moveNode:setNum(moveNum)

				if moveNum == 0 then
					self.moveNode:removeFromParent()
					self.moveNode = nil
					self:getParent():getParent():checkSuccess()
				end
			end
		end
	end

	local function onTouchEnded(pTouch, pEvent)
		if not self.moveNode then return end

		local target = self.moveNode
		local point = pTouch:getLocation()
		target:setPosition(self.startPos)
		target:setBoxVisible(false)

		local num = target:getNum()
		if math.abs(num) == math.abs(selfnum) then
			self:setNum(selfnum)
		else
			local row, line = self.moveNode:getCoordinate()
			local node = GData.level[row][line]
			if node then
				node:setNum(num)
			end
		end
		target:removeFromParent()
		self.moveNode = nil
		self:getParent():getParent():checkSuccess()
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

	listener:setSwallowTouches(true)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
	return listener
end



return BiSprite