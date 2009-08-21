--
-- QChatMods - My personal tweaks to the chat frames and edit box
--
-- Credits: tekkub, Funkydude, the various authors of Chatter, many others, Industrial
--

--[[ Alt-Click Names for Invites ]]
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

--[[ Button Hide Module ]]
local function hide() this:Hide() end --local function to hide the frame

ChatFrameMenuButton:Hide()
for i = 1, NUM_CHAT_WINDOWS do
	local up = _G[format("%s%d%s", "ChatFrame", i, "UpButton")]
	up:SetScript("OnShow", hide)
	up:Hide()
	local down = _G[format("%s%d%s", "ChatFrame", i, "DownButton")]
	down:SetScript("OnShow", hide)
	down:Hide()
	local bottom = _G[format("%s%d%s", "ChatFrame", i, "BottomButton")]
	bottom:SetScript("OnShow", hide)
	bottom:Hide()
end

--[[ Channel Name Abbreviations ]]
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
	["Whisper From"] = "[W:From]",
	["Whisper To"] = "[W:To]"
}

local function replaceChannel(origChannel, msg, num, channel)
	local newChannelName = shortNames[channel] or shortNames[channel:lower()] or msg
	return ("|Hchannel:%s|h%s|h"):format(origChannel, newChannelName)
end

local hooks = {}
local function AddMessage(frame, text, ...)
	if not text then 
		return hooks[frame](frame, text, ...)
	end

	text = gsub(text, "^|Hchannel:(%S-)|h(%[([%d. ]*)([^%]]+)%])|h ", replaceChannel)
	text = gsub(text, "^To ", "[W:To]")
	text = gsub(text, "^(.-|h) whispers:", "[W:From] %1:")
	return hooks[frame](frame, text, ...)
end

local h = nil
for i = 1, NUM_CHAT_WINDOWS do
	h = _G["ChatFrame"..i]
	if h ~= COMBATLOG then -- skip combatlog
		hooks[h] = h.AddMessage
		h.AddMessage = AddMessage
	end
end

--[[		ChatCopy Module		]]--

--TOP, BOTTOM, LEFT, RIGHT, BOTTOMLEFT, BOTTOMRIGHT, TOPLEFT, TOPRIGHT
local BUTTON_POSITION = "BOTTOMRIGHT"
--Try wowhead.com for spell icons
local BUTTON_ICON = "Spell_ChargePositive"

local lines = {}
local frame = nil
local editBox = nil
local f = nil

local function createFrames()
	--[[		Create our frames on demand		]]--
	frame = CreateFrame("Frame", "BCMCopyFrame", UIParent)
	frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 3, right = 3, top = 5, bottom = 3}}
	)
	frame:SetBackdropColor(0,0,0,1)
	frame:SetWidth(500)
	frame:SetHeight(400)
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:Hide()
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "BCMCopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

	editBox = CreateFrame("EditBox", "BCMCopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(400)
	editBox:SetHeight(270)
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)

	scrollArea:SetScrollChild(editBox)

	local close = CreateFrame("Button", "BCMCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

	f = true
end

local function GetLines(...)
	--[[		Grab all those lines		]]--
	local ct = 1
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			lines[ct] = tostring(region:GetText())
			ct = ct + 1
		end
	end
	return ct - 1
end

local function Copy(cf)
	--[[		Stick all the grabbed text into our copying frame		]]--
	local _, size = cf:GetFont()
	FCF_SetChatWindowFontSize(cf, cf, 0.01)
	local lineCt = GetLines(cf:GetRegions())
	local text = table.concat(lines, "\n", 1, lineCt)
	FCF_SetChatWindowFontSize(cf, cf, size)
	if not f then createFrames() end
	frame:Show()
	editBox:SetText(text)
	editBox:HighlightText(0)
end

for i = 1, NUM_CHAT_WINDOWS do
	--[[		Create the magic button		]]--
	local cf = _G[format("ChatFrame%d",  i)]
	--Due to stacking ChatFrames, we have to make 7 buttons instead of 1 :/
	local button = CreateFrame("Button", format("BCMButtonCF%d", i), cf)
	button:SetPoint(BUTTON_POSITION)
	button:SetHeight(10) --LoadUp Height
	button:SetWidth(10) --LoadUp Width
	button:SetNormalTexture("Interface\\Icons\\"..BUTTON_ICON)
	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	button:SetScript("OnClick", function() Copy(cf) end)
	button:SetScript("OnEnter", function()
		button:SetHeight(28) --Big Height
		button:SetWidth(28) --Big Width
		GameTooltip:SetOwner(button)
		GameTooltip:ClearLines()
		GameTooltip:AddLine("Click to copy text.")
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		button:SetHeight(10) --Small Height
		button:SetWidth(10) --Small Width
		GameTooltip:Hide()
	end)
	button:Hide()
	--[[		Show/Hide the button as needed		]]--
	local tab = _G[format("ChatFrame%dTab", i)]
	tab:SetScript("OnShow", function() button:Show() end)
	tab:SetScript("OnHide", function() button:Hide() end)
end

--[[ EditBox Positioning ]]--

local eb = ChatFrameEditBox
eb:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
eb:SetBackdropColor(0,0,0,1)
eb:SetBackdropBorderColor(1,1,1,1)
eb:SetPoint("BOTTOMLEFT",  "ChatFrame1", "TOPLEFT",  -5, 5)
eb:SetPoint("BOTTOMRIGHT", "ChatFrame1", "TOPRIGHT", 45, 5)
eb=nil

--[[ Mouse-wheel Scrolling ]]--

local function scrollChat(frame, delta)
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

for i = 1, NUM_CHAT_WINDOWS do
	local cf = _G["ChatFrame"..i]
	cf:SetScript("OnMouseWheel", scrollChat)
	cf:EnableMouseWheel(true)
end

--[[		Sticky Channels		]]--

--[[		Following are on(1) by default, uncomment them to turn them off		]]--
--ChatTypeInfo.SAY.sticky = 0
--ChatTypeInfo.PARTY.sticky = 0
--ChatTypeInfo.GUILD.sticky = 0
--ChatTypeInfo.RAID.sticky = 0
--ChatTypeInfo.BATTLEGROUND.sticky = 0


--[[		Following are off(0) by default so we turn them on, comment them(--) to turn them off		]]--
ChatTypeInfo.EMOTE.sticky = 1
ChatTypeInfo.YELL.sticky = 1
ChatTypeInfo.OFFICER.sticky = 1
ChatTypeInfo.RAID_WARNING.sticky = 1
ChatTypeInfo.WHISPER.sticky = 1
ChatTypeInfo.CHANNEL.sticky = 1

--[[		Settings		]]--
--Timestamp coloring, http://www.december.com/html/spec/colorcodes.html
local COLOR = "777777"
--Formats decide what time format you want http://www.lua.org/pil/22.1.html
--You can also mix in symbols like %I.%M or or %x:%X
local tformat = "%X"
--Left and right bracket, change to what you want, or make blank "" (Keep the |r)
local lbrack, rbrack = "[", "]|r "


--[[		Timestamp Module		]]--
local date = _G.date
local hooks = {}
local h = nil
local start = "|cff"
local function AddMessage(frame, text, ...)
	text = start..COLOR..lbrack..date(tformat)..rbrack..text
	return hooks[frame](frame, text, ...)
end

--[[			Stamp CF 1 to 7, skip 2		]]--
for i = 1, NUM_CHAT_WINDOWS do
	if i ~= 2 then -- skip combatlog
		h = _G[format("%s%d", "ChatFrame", i)]
		hooks[h] = h.AddMessage
		h.AddMessage = AddMessage
	end
end

--[[
	Stamp Combatlog
	You will need to turn timestamps on
	youself in the combatlog settings
]]--
_G.TEXT_MODE_A_STRING_TIMESTAMP = "|cff"..COLOR.."[%s]|r %s"
--[[		URLCopy Module		]]--
--[[		DON'T MODIFY		]]--

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

--[[		Popup Box		]]--
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

