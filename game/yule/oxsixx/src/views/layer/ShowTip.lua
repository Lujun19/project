--[[
	提示框(小)
]]
local ShowTip = class("ShowTip", function(msg,callback)
		local showTip = display.newLayer()
    return showTip
end)

--默认字体大小
ShowTip.DEF_TEXT_SIZE 	= 26

--UI标识
ShowTip.DG_QUERY_EXIT 	=  2 
ShowTip.BT_CANCEL		=  0   
ShowTip.BT_CONFIRM		=  1

-- 对话框类型
ShowTip.QUERY_SURE 			= 1
ShowTip.QUERY_SURE_CANCEL 	= 2

-- 进入场景而且过渡动画结束时候触发。
function ShowTip:onEnterTransitionFinish()
    return self
end

-- 退出场景而且开始过渡动画时候触发。
function ShowTip:onExitTransitionStart()
	self:unregisterScriptTouchHandler()
    return self
end

--窗外触碰
function ShowTip:setCanTouchOutside(canTouchOutside)
	self._canTouchOutside = canTouchOutside
	return self
end

--msg 显示信息
--callback 交互回调
--txtsize 字体大小
function ShowTip:ctor(msg, callback, txtsize, queryType)
	queryType = queryType or ShowTip.QUERY_SURE_CANCEL
	self._callback = callback
	self._canTouchOutside = true

	local this = self 
	self:setContentSize(appdf.WIDTH,appdf.HEIGHT)
	self:move(0,appdf.HEIGHT)

	--回调函数
	self:registerScriptHandler(function(eventType)
		if eventType == "enterTransitionFinish" then	-- 进入场景而且过渡动画结束时候触发。
			this:onEnterTransitionFinish()
		elseif eventType == "exitTransitionStart" then	-- 退出场景而且开始过渡动画时候触发。
			this:onExitTransitionStart()
		end
	end)

	--按键监听
	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

	--区域外取消显示
	local  onQueryExitTouch = function(eventType, x, y)
		if not self._canTouchOutside then
			return true
		end

		if self._dismiss == true then
			return true
		end

		if eventType == "began" then
			local rect = this:getChildByTag(ShowTip.DG_QUERY_EXIT):getBoundingBox()
        	if cc.rectContainsPoint(rect,cc.p(x,y)) == false then
        		self:dismiss()
    		end
		end
    	return true
    end
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(onQueryExitTouch)

	display.newSprite("query_bg.png")
		:setTag(ShowTip.DG_QUERY_EXIT)
		:move(appdf.WIDTH/2,465)--appdf.HEIGHT/2)
		:addTo(self)

	if ShowTip.QUERY_SURE == queryType then
		ccui.Button:create("bt_query_confirm_0.png","bt_query_confirm_1.png")
			:move(appdf.WIDTH/2 , 395 )
			:setTag(ShowTip.BT_CONFIRM)
			:addTo(self)
			:addTouchEventListener(btcallback)
	else
		ccui.Button:create("bt_query_confirm_0.png","bt_query_confirm_1.png")
			:move(appdf.WIDTH/2+169 , 395 )
			:setTag(ShowTip.BT_CONFIRM)
			:addTo(self)
			:addTouchEventListener(btcallback)

		ccui.Button:create("bt_query_cancel_0.png","bt_query_cancel_1.png")
			:move(appdf.WIDTH/2-169 ,395 )
			:setTag(ShowTip.BT_CANCEL)
			:addTo(self)
			:addTouchEventListener(btcallback)
	end

	cc.Label:createWithTTF("系统消息", "fonts/round_body.ttf", 32)
		:setTextColor(cc.c4b(255,221,65,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:setDimensions(600, 120)
		:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:move(appdf.WIDTH/2 ,545 )
		:addTo(self)

	cc.Label:createWithTTF(msg, "fonts/round_body.ttf", not txtsize and ShowTip.DEF_TEXT_SIZE or txtsize)
		:setTextColor(cc.c4b(255,255,255,255))
		:setAnchorPoint(cc.p(0.5,0.5))
		:setDimensions(600, 180)
		:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		:move(appdf.WIDTH/2 ,470 )
		:addTo(self)
	self._dismiss  = false
	self:runAction(cc.MoveTo:create(0.3,cc.p(0,0)))
end

--按键点击
function ShowTip:onButtonClickedEvent(tag,ref)
	if self._dismiss == true then
		return
	end
	--取消显示
	self:dismiss()
	--通知回调
	if self._callback then
		self._callback(tag == ShowTip.BT_CONFIRM)
	end
end

--取消消失
function ShowTip:dismiss()
	self._dismiss = true
	local this = self
	self:stopAllActions()
	self:runAction(
		cc.Sequence:create(
			cc.MoveTo:create(0.3,cc.p(0,appdf.HEIGHT)),
			cc.CallFunc:create(function()
					this:removeSelf()
				end)
			))	
end

return ShowTip
