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
