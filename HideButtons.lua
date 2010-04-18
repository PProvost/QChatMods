local addonName, ns = ...

local function hideFrameForever(f) 
	f:SetScript("OnShow", f.Hide)
	f:Hide() 
end 

ChatFrameMenuButton:Hide()

for i = 1, NUM_CHAT_WINDOWS do
	-- Hide buttons
	hideFrameForever(_G['ChatFrame'..i..'UpButton'])
	hideFrameForever(_G['ChatFrame'..i..'DownButton'])
	hideFrameForever(_G['ChatFrame'..i..'BottomButton'])
end

