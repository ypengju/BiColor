
local funcs = {}

--获取点击node的范围
local function getBoundingBox(node)
	local x, y = node:getPosition()

	local size = cc.size(100, 100)
	if node:getName() == "BigLevelBg" then
		size = cc.Director:getInstance():getVisibleSize()
	else
		size = node:getSize()
	end
	local rect = cc.rect(x-size.width/2, y-size.height/2, size.width, size.height)
	return rect
end


function funcs.addClick(node, callback)
	-- local startPos = cc.p(node:getPositionX(), node:getPositionY())
	local beginPos = nil
	local isMove = false
	local function onTouchBegan(pTouch, pEvent)
		local target = pEvent:getCurrentTarget()
		local point = pTouch:getLocation()
		beginPos = point
		isMove = false
		return true
	end
	local function onTouchMoved(pTouch, pEvent)
		local point = pTouch:getLocation()
		local dis = cc.pGetDistance(beginPos, point)
		if dis > 10 then
			isMove = true
		end
	end
	local function onTouchEnded(pTouch, pEvent)
		if not isMove then
			local target = pEvent:getCurrentTarget()
			local point = pTouch:getLocation()
			local rect = getBoundingBox(target)
			local flag = cc.rectContainsPoint(rect, point)
			if flag then
				if callback then
					callback(target)
				end
			end
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

	listener:setSwallowTouches(false)
	node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
	return listener
end

function funcs.pushRecord(curNode, nextNode)
	local t = {}
	t.curNode = curNode
	t.nextNode = nextNode
	table.insert(GData.record, t)
end

function funcs.popRecord()
	return table.remove(GData.record)
end

function funcs.clearRecord()
	GData.record = {}
end

function funcs.pushBackRecord(node)
	table.insert(GData.backrecord, node)
end

function funcs.popBackRecord()
	return table.remove(GData.backrecord)
end

function funcs.clearBackRecord()
	GData.backrecord = {}
end


function funcs.checkMove(curNode, nextNode)
	local result = false
	local state = curNode:getState()
	local nodeState = nextNode:getState()
	if not tolua.isnull(nextNode) and state ~= nodeState and nextNode:getNum() == 0 then
		result = true
	end
	return result
end


function funcs.moveDirection(curNode, nextNode, isback)
	if nextNode:getNum() > 0 then

	elseif nextNode:getNum() < 0 then

	elseif nextNode:getNum() == 0 then
		if not isback then
			local state = curNode:getState()
			nextNode:setState(state)
			if curNode:getNum() > 0 then
				local num = curNode:getNum()
				curNode:setNum(0)
				nextNode:setNum(num - 1)
				nextNode:setNumVisible(false)
			elseif curNode:getNum() < 0 then
				local num = curNode:getNum()
				curNode:setNum(0)
				nextNode:setNum(num + 1)
				nextNode:setNumVisible(false)
			end
		else
			local state = curNode:getState()
			state = state == 1 and 2 or 1
			curNode:setState(state)

			if curNode:getNum() >= 0 then
				local num = curNode:getNum()
				curNode:setNum(0)
				nextNode:setNum(num + 1)
			elseif curNode:getNum() < 0 then
				local num = curNode:getNum()
				curNode:setNum(0)
				nextNode:setNum(num - 1)
			end
		end
	end
end

return funcs