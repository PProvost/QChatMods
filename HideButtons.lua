local addonName, ns = ...

local function hideFrameForever(f) 
	f:SetScript("OnShow", f.Hide)
	f:Hide() 
end 

hideFrameForever(ChatFrameMenuButton)
hideFrameForever(FriendsMicroButton)

for i = 1, NUM_CHAT_WINDOWS do
	-- Hide buttons
	hideFrameForever(_G['ChatFrame'..i..'ButtonFrame'])
end

