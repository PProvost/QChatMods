--
-- QChatMods - My personal tweaks to the chat frames and edit box
--
-- Thanks to Industrial, Funkydude, the various authors of Chatter, and many others for
-- the tips and tricks used here.
--

local shortNames = {
	["Guild"] = "[G]",
	["Officer"] = "[O]",
	["Party"] = "[P]",
	["Raid"] = "[R]",
	["Raid Leader"] = "[RL]",
	["Raid Warning"] = "[RW]",
	["LookingForGroup"] = "[LFG]",
	["Battleground"] = "[BG]",
	["Battleground Leader"] = "[BL]",
}

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
local date = _G.date
local hooks = {}
local function AddMessage(frame, text, ...)
	if not text then return hooks[frame](frame, text, ...) end

	-- Channel name replacement
	text = gsub(text, "^|Hchannel:(%S-)|h(%[([%d. ]*)([^%]]+)%])|h ", replaceChannel)
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

--[[ Hide the main chat menu button ]]
ChatFrameMenuButton:Hide()

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

--[[ Timestamp format for Combatlog ]]--
_G.TEXT_MODE_A_STRING_TIMESTAMP = "|cff"..TIMESTAMP_COLOR.."[%s]|r %s"

--[[ Tweak the Chat Windows ]]--
do 
	local cf = nil
	for i = 1, NUM_CHAT_WINDOWS do
		cf = _G["ChatFrame"..i]

		-- Only do channel name and timestamps on non-combat log frames
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
