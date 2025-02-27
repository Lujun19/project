--
-- Author: zhong
-- Date: 2016-10-12 15:22:32
--
local RoomLayerModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameRoomLayerModel")
local GameRoomLayer = class("GameRoomLayer", RoomLayerModel)

--获取桌子参数(背景、椅子布局)
function GameRoomLayer:getTableParam()
    local table_bg = cc.Sprite:create("game/yule/zhajinhua/res/roomlist/roomtable.png")

    if nil ~= table_bg then
        local bgSize = table_bg:getContentSize()
        --桌号背景
        display.newSprite("Room/bg_tablenum.png")
            :addTo(table_bg)
            :move(bgSize.width * 0.5,10)
        ccui.Text:create("", "base/fonts/round_body.ttf", 16)
            :addTo(table_bg)
            :setColor(cc.c4b(255,193,200,255))
            :setTag(1)
            :move(bgSize.width * 0.5,12)
        --状态
        display.newSprite("Room/flag_waitstatus.png")
            :addTo(table_bg)
            :setTag(2)
            :move(bgSize.width * 0.5,98)
    end    

	--modify by liuyang 20170913
    --return table_bg, {cc.p(-3,160),cc.p(170,220),cc.p(342,160),cc.p(310,6),cc.p(30,6)}
	return table_bg, {cc.p(-20,100),cc.p(33,200),cc.p(170,220),cc.p(304,200),cc.p(360,100),cc.p(304,0),cc.p(33,0)}
end

return GameRoomLayer