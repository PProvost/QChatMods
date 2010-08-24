local addonName, ns = ...

local eb = ChatFrame1EditBox

--[[ Enable history without Alt pressed ]]--
eb:SetAltArrowKeyMode(false)

-- Change the look-and-feel
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

-- Position and size
eb:ClearAllPoints()
eb:SetPoint("BOTTOMLEFT",  "ChatFrame1", "TOPLEFT",  -5, 5)
eb:SetPoint("BOTTOMRIGHT", "ChatFrame1", "TOPRIGHT", 45, 5)

