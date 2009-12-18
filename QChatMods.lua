--
-- QChatMods - My personal tweaks to the chat frames and edit box
--
-- Thanks to Industrial, Funkydude, tekkub, the various authors of Chatter, and many others for
-- the tips and tricks used here.
--

local strmatch = _G.string.match
local date = _G.date
local IsAltKeyDown = _G.IsAltKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown 
local IsControlKeyDown = _G.IsControlKeyDown
local ShowUIPanel = _G.ShowUIPanel
local HideUIPanel = _G.HideUIPanel

local shortNames = {
	["Guild"] = "[G]",
	["Officer"] = "[O]",
	["Party"] = "[P]",
	["Party Leader"] = "[PL]",
	["Raid"] = "[R]",
	["Raid Leader"] = "[RL]",
	["Raid Warning"] = "[RW]",
	["LookingForGroup"] = "[LFG]",
	["Battleground"] = "[BG]",
	["Battleground Leader"] = "[BL]",
}

local hooks = {}

--[[ Pre-hook SetItemRef to enable Alt-click on names for Invites ]]
local setItemRefOrig = SetItemRef
function SetItemRef(link, text, button)
	local linkType = string.sub(link, 1, 6)
	if IsAltKeyDown() and linkType == "player" then
		local name = string.match(link, "player:([^:]+)")
		InviteUnit(name)
		return nil
	end
	return setItemRefOrig(link, text, button)
end

--[[ Uber frame hider function ]]--
local function hideFrameForever(f) 
	f:SetScript("OnShow", f.Hide)
	f:Hide() 
end 

--[[ Channel name shortening helper function ]]--
local function replaceChannelName(origChannel, msg, num, channel)
	local newChannelName = shortNames[channel] or shortNames[channel:lower()] or msg
	return ("|Hchannel:%s|h%s|h"):format(origChannel, newChannelName)
end

--[[ Hook function for the ChatFrame.AddMessage function. ]]--
local function AddMessage(frame, text, ...)
	if not text then return hooks[frame](frame, text, ...) end

	-- Channel name replacement
	text = gsub(text, "^|Hchannel:(%S-)|h(%[([%d. ]*)([^%]]+)%])|h ", replaceChannelName)
	text = gsub(text, "^To ", "[W:To]")
	text = gsub(text, "^(.-|h) whispers:", "[W:From] %1:")

	-- Timestamps
	text = "|cff777777["..date("%X").."]|r"..text

	return hooks[frame](frame, text, ...)
end

--[[ OnMouseWheel script for chat frame mouse scrolling ]]
local function ChatFrame_OnMouseWheel(frame, delta)
	if delta > 0 then
		if IsShiftKeyDown() then
			frame:ScrollToTop()
		elseif IsControlKeyDown() then
			frame:PageUp()
		else
			frame:ScrollUp()
		end
	elseif delta < 0 then
		if IsShiftKeyDown() then
			frame:ScrollToBottom()
		elseif IsControlKeyDown() then
			frame:PageDown()
		else
			frame:ScrollDown()
		end
	end
end

do ---[[ EditBox Positioning and Texturing ]]--
	local eb = ChatFrameEditBox
	local x=({eb:GetRegions()})
	x[6]:SetAlpha(0); x[7]:SetAlpha(0); x[8]:SetAlpha(0)
	eb:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	eb:SetBackdropColor(0,0,0,1)
	eb:SetBackdropBorderColor(1,1,1,1)
	eb:ClearAllPoints()
	eb:SetPoint("BOTTOMLEFT",  "ChatFrame1", "TOPLEFT",  -5, 5)
	eb:SetPoint("BOTTOMRIGHT", "ChatFrame1", "TOPRIGHT", 45, 5)
	eb=nil
end

--[[ Hide the main chat menu button ]]--
ChatFrameMenuButton:Hide()

--[[ Enable history without Alt pressed ]]--
ChatFrameEditBox:SetAltArrowKeyMode(false)

--[[ Set sticky channels ]]
ChatTypeInfo.SAY.sticky = 1
ChatTypeInfo.EMOTE.sticky = 1
ChatTypeInfo.YELL.sticky = 1
ChatTypeInfo.PARTY.sticky = 1
ChatTypeInfo.GUILD.sticky = 1
ChatTypeInfo.OFFICER.sticky = 1
ChatTypeInfo.RAID.sticky = 1
ChatTypeInfo.RAID_WARNING.sticky = 1
ChatTypeInfo.BATTLEGROUND.sticky = 1
ChatTypeInfo.WHISPER.sticky = 1
ChatTypeInfo.CHANNEL.sticky = 1

-- This doesn't seem to work. I need to look into using SetChatColorNameByClass instead
for k,v in pairs(ChatTypeInfo) do
	if v.colorNameByClass then
		v.colorNameByClass = true
	end
end

local channelColors = {
	ACHIEVEMENT= {1.000000059139,1.000000059139,0},
	AFK= {1.000000059139,0.50196081399918,1.000000059139},
	BATTLEGROUND= {1.000000059139,0.49803924513981,0},
	BATTLEGROUND_LEADER= {1.000000059139,0.85882358020172,0.71764710126445},
	BG_SYSTEM_ALLIANCE= {0,0.68235298153013,0.93725495738909},
	BG_SYSTEM_HORDE= {1.000000059139,0,0},
	BG_SYSTEM_NEUTRAL= {1.000000059139,0.47058826312423,0.039215688593686},
	CHANNEL10= {1.000000059139,0.75294122099876,0.75294122099876},
	CHANNEL1= {1.000000059139,0.75294122099876,0.75294122099876},
	CHANNEL2= {1.000000059139,0.75294122099876,0.75294122099876},
	CHANNEL3= {1.000000059139,0.75294122099876,0.75294122099876},
	CHANNEL4= {1.000000059139,0.89019613107666,0.27843138901517},
	CHANNEL5= {0.8980392687954,0.60000003548339,0.34117649076506},
	CHANNEL6= {1.000000059139,0.75294122099876,0.75294122099876},
	CHANNEL7= {1.000000059139,0.75294122099876,0.75294122099876},
	CHANNEL8= {1.000000059139,0.75294122099876,0.75294122099876},
	CHANNEL9= {1.000000059139,0.75294122099876,0.75294122099876},
	CHANNEL= {0.75294122099876,0.50196081399918,0.50196081399918},
	CHANNEL_JOIN= {0.75294122099876,0.50196081399918,0.50196081399918},
	CHANNEL_LEAVE= {0.75294122099876,0.50196081399918,0.50196081399918},
	CHANNEL_LIST= {0.75294122099876,0.50196081399918,0.50196081399918},
	CHANNEL_NOTICE= {0.75294122099876,0.75294122099876,0.75294122099876},
	CHANNEL_NOTICE_USER= {0.75294122099876,0.75294122099876,0.75294122099876},
	COMBAT_FACTION_CHANGE= {0.50196081399918,0.50196081399918,1.000000059139},
	COMBAT_HONOR_GAIN= {0.87843142449856,0.79215690959245,0.039215688593686},
	COMBAT_MISC_INFO= {0.50196081399918,0.50196081399918,1.000000059139},
	COMBAT_XP_GAIN= {0.43529414338991,0.43529414338991,1.000000059139},
	DND= {1.000000059139,0.50196081399918,1.000000059139},
	EMOTE= {1.000000059139,0.50196081399918,0.25098040699959},
	FILTERED= {1.000000059139,0,0},
	GUILD= {0.25098040699959,1.000000059139,0.25098040699959},
	GUILD_ACHIEVEMENT= {0.25098040699959,1.000000059139,0.25098040699959},
	IGNORED= {1.000000059139,0,0},
	LOOT= {0,0.66666670609266,0},
	MONEY= {1.000000059139,1.000000059139,0},
	MONSTER_EMOTE= {1.000000059139,0.50196081399918,0.25098040699959},
	MONSTER_PARTY= {0.66666670609266,0.66666670609266,1.000000059139},
	MONSTER_SAY= {1.000000059139,1.000000059139,0.6235294486396},
	MONSTER_WHISPER= {1.000000059139,0.70980396354571,0.92156868195161},
	MONSTER_YELL= {1.000000059139,0.25098040699959,0.25098040699959},
	OFFICER= {0.75294122099876,0,0.14901961665601},
	OPENING= {0.50196081399918,0.50196081399918,1.000000059139},
	PARTY= {0.66666670609266,0.66666670609266,1.000000059139},
	PARTY_LEADER= {0.46274512540549,0.78431377187371,1.000000059139},
	PET_INFO= {0.50196081399918,0.50196081399918,1.000000059139},
	RAID= {1.000000059139,0.49803924513981,0},
	RAID_BOSS_EMOTE= {1.000000059139,0.86666671792045,0},
	RAID_BOSS_WHISPER= {1.000000059139,0.86666671792045,0},
	RAID_LEADER= {1.000000059139,0.28235295787454,0.035294119734317},
	RAID_WARNING= {1.000000059139,0.28235295787454,0},
	REPLY= {1.000000059139,0.50196081399918,1.000000059139},
	RESTRICTED= {1.000000059139,0,0},
	SAY= {1.000000059139,1.000000059139,1.000000059139},
	SKILL= {0.33333335304633,0.33333335304633,1.000000059139},
	SYSTEM= {1.000000059139,1.000000059139,0},
	TEXT_EMOTE= {1.000000059139,0.50196081399918,0.25098040699959},
	TRADESKILLS= {1.000000059139,1.000000059139,1.000000059139},
	WHISPER= {1.000000059139,0.50196081399918,1.000000059139},
	WHISPER_INFORM= {1.000000059139,0.50196081399918,1.000000059139},
	YELL= {1.000000059139,0.25098040699959,0.25098040699959},
}

--[[
-- Color the channels consistently and permanently
-- You can dump current channels with something like this:
-- for k,v in pairs(ChatTypeInfo) do
--    print( GetMessageTypeColor(k) )
-- end
--]]
for k,v in pairs(channelColors) do
	ChangeChatColor(tostring(k), v[1], v[2], v[3])
end

--[[ Timestamp format for Combatlog ]]--
_G.TEXT_MODE_A_STRING_TIMESTAMP = "|cff77777777[%s]|r %s"

--[[ Tweak the Chat Windows ]]--
do 
	local cf = nil
	for i = 1, NUM_CHAT_WINDOWS do
		cf = _G["ChatFrame"..i]

		-- Only do channel name, timestamps and hyperlink hooking on non-combat log frames
		if cf ~= COMBATLOG then 
			hooks[cf] = cf.AddMessage
			cf.AddMessage = AddMessage
		end

		-- Mouse wheel scrolling
		cf:EnableMouseWheel(true)
		cf:SetScript("OnMouseWheel", ChatFrame_OnMouseWheel)

		-- Hide buttons
		hideFrameForever(_G['ChatFrame'..i..'UpButton'])
		hideFrameForever(_G['ChatFrame'..i..'DownButton'])
		hideFrameForever(_G['ChatFrame'..i..'BottomButton'])
	end
end

--[[ URLCopy -- from BasicChatMods ]]-- 
do  
	local currentLink = nil
	local ref = _G["SetItemRef"]
	local gsub = _G.string.gsub
	local ipairs = _G.ipairs
	local pairs = _G.pairs
	local fmt = _G.string.format
	local sub = _G.string.sub

	local tlds = {
		COM = true,
		UK = true,
		NET = true,
		INFO = true,
		CO = true,
		DE = true,
		FR = true,
		ES = true,
		BE = true,
		CC = true,
		US = true,
		KO = true,
		CH = true,
		TW = true,
	}
	local style = "|cffffffff|Hurl:%s|h[%s]|h|r"
	local tokennum, matchTable = 1, {}
	local function RegisterMatch(text)
		local token = "\255\254\253"..tokennum.."\253\254\255"
		matchTable[token] = strreplace(text, "%", "%%")
		tokennum = tokennum + 1
		return token
	end
	local function Link(link, ...)
		if not link then
			return ""
		end
		return RegisterMatch(fmt(style, link, link))
	end
	local function Link_TLD(link, tld, ...)
		if not link or not tld then
			return ""
		end
		if tlds[strupper(tld)] then
			return RegisterMatch(fmt(style, link, link))
		else
			return RegisterMatch(link)
		end
	end

	local patterns = {
		-- X://Y url
		{ pattern = "^(%a[%w%.+-]+://%S+)", matchfunc=Link},
		{ pattern = "%f[%S](%a[%w%.+-]+://%S+)", matchfunc=Link},
		-- www.X.Y url
		{ pattern = "^(www%.[%w_-%%]+%.%S+)", matchfunc=Link},
		{ pattern = "%f[%S](www%.[%w_-%%]+%.%S+)", matchfunc=Link},
		-- X@Y.Z email
		{ pattern = "(%S+@[%w_-%%%.]+%.(%a%a+))", matchfunc=Link_TLD},
		-- X.Y.Z/WWWWW url with path
		{ pattern = "^([%w_-%%%.]+[%w_-%%]%.(%a%a+)/%S+)", matchfunc=Link_TLD},
		{ pattern = "%f[%S]([%w_-%%%.]+[%w_-%%]%.(%a%a+)/%S+)", matchfunc=Link_TLD},
		-- X.Y.Z url
		{ pattern = "^([%w_-%%%.]+[%w_-%%]%.(%a%a+))", matchfunc=Link_TLD},
		{ pattern = "%f[%S]([%w_-%%%.]+[%w_-%%]%.(%a%a+))", matchfunc=Link_TLD},
	}

	local function filterFunc(self, event, msg, ...)
		for _, v in ipairs(patterns) do
			msg = gsub(msg, v.pattern, v.matchfunc)
		end
		for k,v in pairs(matchTable) do
			msg = gsub(msg, k, v)
			matchTable[k] = nil
		end
		return false, msg, ...
	end

	local function AddEvents()
		local events = {
			"CHAT_MSG_CHANNEL", "CHAT_MSG_YELL",
			"CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
			"CHAT_MSG_PARTY", "CHAT_MSG_RAID",
			"CHAT_MSG_RAID_LEADER",
			"CHAT_MSG_SAY", "CHAT_MSG_WHISPER",
		}
		for _,event in ipairs(events) do
			ChatFrame_AddMessageEventFilter(event, filterFunc)
		end
	end
	AddEvents()

	local function SetItem(link, ...)
		if sub(link, 1, 3) == "url" then
			currentLink = sub(link, 5)
			StaticPopup_Show("BCMUrlCopyDialog")
			return
		end
		return ref(link, ...)
	end
	_G["SetItemRef"] = SetItem

	--		Popup Box		--
	StaticPopupDialogs["BCMUrlCopyDialog"] = {
		text = "URL",
		button2 = TEXT(CLOSE),
		hasEditBox = 1,
		hasWideEditBox = 1,
		showAlert = 1,
		OnShow = function()
			local editBox = _G[this:GetName().."WideEditBox"]
			editBox:SetText(currentLink)
			editBox:SetFocus()
			editBox:HighlightText(0)
			local button = _G[this:GetName().."Button2"]
			button:ClearAllPoints()
			button:SetWidth(200)
			button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
			_G[this:GetName().."AlertIcon"]:Hide()
		end,
		EditBoxOnEscapePressed = function() this:GetParent():Hide() end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
	}
end
