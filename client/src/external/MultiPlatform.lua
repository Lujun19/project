--
-- Author: zhong
-- Date: 2016-07-29 17:10:55
--

--[[
* 跨平台管理
* tip: require 该模块时路径要统一 "client.src.external.MultiPlatform"
]]

local MultiPlatform = class("MultiPlatform")

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

--平台
local PLATFORM = {}
PLATFORM[cc.PLATFORM_OS_ANDROID] = appdf.EXTERNAL_SRC .. "platform.Bridge_android"
PLATFORM[cc.PLATFORM_OS_IPHONE] = appdf.EXTERNAL_SRC .. "platform.Bridge_ios"
PLATFORM[cc.PLATFORM_OS_IPAD] = appdf.EXTERNAL_SRC .. "platform.Bridge_ios"
PLATFORM[cc.PLATFORM_OS_MAC] = appdf.EXTERNAL_SRC .. "platform.Bridge_ios"

function MultiPlatform:ctor()
	self.sDefaultTitle = ""
	self.sDefaultContent = ""
	self.sDefaultUrl = ""
end

--实现单例
MultiPlatform._instance = nil
function MultiPlatform:getInstance(  )
	if nil == MultiPlatform._instance then
		print("new instance")
		MultiPlatform._instance = MultiPlatform:create()
	end
	return MultiPlatform._instance
end

function MultiPlatform:getSupportPlatform()
    --return cc.PLATFORM_OS_WINDOWS
	local plat = targetPlatform
	--ios特殊处理
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
		plat = cc.PLATFORM_OS_IPHONE
	end

	return plat
end

--获取设备id
function MultiPlatform:getMachineId()
	local plat = self:getSupportPlatform()

	 local unionid = tostring(math.random(80,99));

	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getMachineId then
		return g_var(PLATFORM[plat]).getMachineId()
	else
		print("平台不支持" .. plat)
		return "A501164B366ECFC9E"..tostring(math.random(7,9)).."49163873094D"..unionid
		-- return "A501164B366ECFC9E0449163873094D51"
		-- return "A501164B366ECFC9E0449163873094D40"
	end
end

--获取设备ip
function MultiPlatform:getClientIpAdress()
	local plat = self:getSupportPlatform()

	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getMachineId then
		return g_var(PLATFORM[plat]).getClientIpAdress( )
	else
		print("平台不支持" .. plat)
		return "192.168.1.1"..tostring(math.random(0,9));
	end
end

--获取外部存储可写文档目录
function MultiPlatform:getExtralDocPath()
	local plat = self:getSupportPlatform()
	local path = device.writablePath
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getExtralDocPath then
		path = g_var(PLATFORM[plat]).getExtralDocPath( )
	else
		print("undefined funtion or 平台不支持" .. plat)
	end

	if false == cc.FileUtils:getInstance():isDirectoryExist(path) then
		cc.FileUtils:getInstance():createDirectory(path)
	end
	return path
end

-- 选择图片
-- callback 回调函数
-- needClip 是否需要裁减图片
function MultiPlatform:triggerPickImg( callback, needClip )
	local plat = self:getSupportPlatform()

	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).triggerPickImg then
		g_var(PLATFORM[plat]).triggerPickImg( callback, needClip )
	else
		print("平台不支持" .. plat)
	end
end

--配置第三方平台
function MultiPlatform:thirdPartyConfig(thirdparty, configTab)
	configTab = configTab or {}

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).thirdPartyConfig then
		g_var(PLATFORM[plat]).thirdPartyConfig( thirdparty, configTab )
	else
		print("平台不支持" .. plat)
	end
end

--分享相关
function MultiPlatform:configSocial(socialTab)
	socialTab = socialTab or {}
	socialTab.title = socialTab.title or ""
	socialTab.content = socialTab.content or ""
	socialTab.url = socialTab.url or ""

	self.sDefaultTitle = socialTab.title
	self.sDefaultContent = socialTab.content
	self.sDefaultUrl = socialTab.url

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).configSocial then
		g_var(PLATFORM[plat]).configSocial( socialTab )
	else
		print("平台不支持" .. plat)
	end
end

--第三方登陆
function MultiPlatform:thirdPartyLogin(thirdparty, callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).thirdPartyLogin then
		return g_var(PLATFORM[plat]).thirdPartyLogin( thirdparty, callback )
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

--分享
function MultiPlatform:startShare(callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	-- 判断微信配置
	if yl.WeChat.AppID == "" or yl.WeChat.AppID == " " then
		local runScene = cc.Director:getInstance():getRunningScene()
		if nil ~= runScene then
			showToast(runScene, "分享失败, 错误代码:" .. yl.ShareErrorCode.NOT_CONFIG, 2, cc.c4b(250,255,255,255))
		end
		return false, "not config wechat"
	end

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).startShare then
		return g_var(PLATFORM[plat]).startShare( callback )
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

--自定义分享
-- imgOnly 值为字符串 "true" 表示只分享图片
function MultiPlatform:customShare( callback, title, content, url, img, imgOnly )
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	-- 判断微信配置
	if yl.WeChat.AppID == "" or yl.WeChat.AppID == " " then
		local runScene = cc.Director:getInstance():getRunningScene()
		if nil ~= runScene then
			showToast(runScene, "分享失败, 错误代码:" .. yl.ShareErrorCode.NOT_CONFIG, 2, cc.c4b(250,255,255,255))
		end
		return false, "not config wechat"
	end

	title = title or self.sDefaultTitle
	content = content or self.sDefaultContent
	img = img or ""
	url = url or self.sDefaultUrl
	imgOnly = imgOnly or "false"

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).customShare then
		return g_var(PLATFORM[plat]).customShare( title,content,url,img, imgOnly,callback )
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

-- 分享到指定平台
function MultiPlatform:shareToTarget( target, callback, title, content, url, img, imgOnly )
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	-- 判断微信配置
	if yl.WeChat.AppID == "" or yl.WeChat.AppID == " " then
		local runScene = cc.Director:getInstance():getRunningScene()
		if nil ~= runScene then
			showToast(runScene, "分享失败, 错误代码:" .. yl.ShareErrorCode.NOT_CONFIG, 2, cc.c4b(250,255,255,255))
		end
		return false, "not config wechat"
	end

	title = title or self.sDefaultTitle
	content = content or self.sDefaultContent
	img = img or ""
	url = url or self.sDefaultUrl
	imgOnly = imgOnly or "false"

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).shareToTarget then
		return g_var(PLATFORM[plat]).shareToTarget( target, title, content, url, img, imgOnly, callback )
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

--第三方支付
--[[
payparam =
{
	price,
	count,
	productname,
	orderid,
}
]]
function MultiPlatform:thirdPartyPay(thirdparty, payparamTab, callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	payparamTab = payparamTab or {}

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).thirdPartyPay then
		return g_var(PLATFORM[plat]).thirdPartyPay( thirdparty, payparamTab, callback )
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

--竣付通获取支付列表
function MultiPlatform:getPayList(token, callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).getPayList then
		return g_var(PLATFORM[plat]).getPayList( token, callback )
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

--第三方平台是否安装
function MultiPlatform:isPlatformInstalled(thirdparty)
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).isPlatformInstalled then
		return g_var(PLATFORM[plat]).isPlatformInstalled( thirdparty )
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

--图片存储至系统相册
function MultiPlatform:saveImgToSystemGallery(filepath, filename)
	if false == cc.FileUtils:getInstance():isFileExist(filepath) then
		local msg = filepath .. " not exist"
		print(msg)
		return false, msg
	end
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).saveImgToSystemGallery then
		return g_var(PLATFORM[plat]).saveImgToSystemGallery( filepath, filename )
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

-- 录音权限判断
function MultiPlatform:checkRecordPermission()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).checkRecordPermission then
		return g_var(PLATFORM[plat]).checkRecordPermission( )
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

-- 请求单次定位
function MultiPlatform:requestLocation(callback)
	callback = callback or -1

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).requestLocation then
		return g_var(PLATFORM[plat]).requestLocation(callback)
	else
		local msg = "平台不支持" .. plat
		print(msg)
		if type(callback) == "function" then
			callback("")
		end
		return false, msg
	end
end

-- 计算距离
function MultiPlatform:metersBetweenLocation( loParam )
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).metersBetweenLocation then
		return g_var(PLATFORM[plat]).metersBetweenLocation(loParam)
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

-- 请求通讯录
function MultiPlatform:requestContact(callback)
	callback = callback or -1

	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).requestContact then
		return g_var(PLATFORM[plat]).requestContact(callback)
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

-- 启动浏览器
function MultiPlatform:openBrowser( url )
	url = url or BaseConfig.WEB_HTTP_URL
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).openBrowser then
		return g_var(PLATFORM[plat]).openBrowser(url)
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return false, msg
	end
end

-- 复制到剪贴板
function MultiPlatform:copyToClipboard( msg )
	-- print("msg")
	-- dump(msg)
	-- if true then
	-- 	return
	-- end
	if type(msg) ~= "string" then
		print("复制内容非法")
		return 0, "复制内容非法"
	end
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).copyToClipboard then
		return g_var(PLATFORM[plat]).copyToClipboard(msg)
	else
		local msg = "平台不支持" .. plat
		print(msg)
		return 0, msg
	end
end

-- 是否允许定位判断
function MultiPlatform:isOpenLocation()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).isOpenLocation then
		return g_var(PLATFORM[plat]).isOpenLocation()
	else
		return false
	end
end

-- 调用 客服界面
function MultiPlatform:presentServiceViewController( userid,signature,time,url, headurl)

    local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) then
		return g_var(PLATFORM[plat]).presentServiceViewController( userid,signature,time,url, headurl)
	else
		return false
	end
end
--内嵌网页
function MultiPlatform:openWebview( url)

    local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) and nil ~= g_var(PLATFORM[plat]).openWebview then
		return g_var(PLATFORM[plat]).openWebview( url)
	else
		return false
	end
end

-- 注册 iOS App 活动状态 回调
function MultiPlatform:registerActiveStatusCallBack( callback )
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	--	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
 	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
		local plat = self:getSupportPlatform()
		if nil ~= g_var(PLATFORM[plat]) then
			return g_var(PLATFORM[plat]).registerActiveStatusCallBack( callback )
		else
			return false
		end
    end
end

--设置极光推送别名,传入参数 ：userid ，用于给该“userid”的用户 单独推送 远程通知消息
function MultiPlatform:setAlias( account )
    local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) then
		--return g_var(PLATFORM[plat]).setAlias(account)
        return true
	else
		return false
	end
end

--删除极光推送别名，退出登录时，要删除 极光推送别名，这样才能切换通知用户
function MultiPlatform:deleteAlias()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) then
		--return g_var(PLATFORM[plat]).deleteAlias()
        return true
	else
		return false
	end
end

function MultiPlatform:openQQ()
	local plat = self:getSupportPlatform()
	if nil ~= g_var(PLATFORM[plat]) then
		return g_var(PLATFORM[plat]).openQQ()
	else
		return false
	end
end

return MultiPlatform

--[[

--local VoiceRecorderKit = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.game.VoiceRecorderKit")

local l =
		{
			myLatitude = 22.51,
			myLongitude = 113.94,
			otherLatitude = 23.51,
			otherLongitude = 114.94
		}
		print(MultiPlatform:getInstance():metersBetweenLocation(l))

MultiPlatform:getInstance():requestLocation(function(res)
			local ok, datatable = pcall(function()
				return cjson.decode(res)
			end)
			if ok then
				dump(datatable, " location data", 6)
			end
		end)
]]
