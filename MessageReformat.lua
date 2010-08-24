local addonName, ns = ...

local debugf = tekDebug and tekDebug:GetFrame(addonName)
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

local shortNames = {
	["Guild"] = "[G]",
	["Officer"] = "[O]",
	["Party"] = "[P]",
	["Party Leader"] = "[PL]",
	["Dungeon Guide"] = "[DG]",
	["Raid"] = "[R]",
	["Raid Leader"] = "[RL]",
	["Raid Warning"] = "[RW]",
	["LookingForGroup"] = "[LFG]",
	["Battleground"] = "[BG]",
	["Battleground Leader"] = "[BL]",
}

local hooks = {}

--[[ Channel name shortening helper function ]]--
local function replaceChannelName(origChannel, msg, num, channel)
	local newChannelName = shortNames[channel] or shortNames[channel:lower()] or msg
	return (BetterDate(CHAT_TIMESTAMP_FORMAT, time()).."|Hchannel:%s|h%s|h"):format(origChannel, newChannelName)
end

	--[[ Hook function for the ChatFrame.AddMessage function. ]]--
local function AddMessage(frame, text, ...)
	if not text then return hooks[frame](frame, text, ...) end

	Debug(gsub(text, "|", "||"))

	-- Channel name replacement
	text = gsub(text, "^%d+:%d+:%d+ |Hchannel:(%S-)|h(%[([%d. ]*)([^%]]+)%])|h ", replaceChannelName)
	text = gsub(text, "^%d+:%d+:%d+ To ", BetterDate(CHAT_TIMESTAMP_FORMAT, time()).."[W:To]")
	text = gsub(text, "^%d+:%d+:%d+ (.-|h) whispers:", BetterDate(CHAT_TIMESTAMP_FORMAT, time()).."[W:From] %1:")

	return hooks[frame](frame, text, ...)
end

local cf = nil
for i = 1, NUM_CHAT_WINDOWS do
	cf = _G["ChatFrame"..i]

	-- Only do channel name, timestamps and hyperlink hooking on non-combat log frames
	if cf ~= COMBATLOG then 
		hooks[cf] = cf.AddMessage
		cf.AddMessage = AddMessage
	end
end

