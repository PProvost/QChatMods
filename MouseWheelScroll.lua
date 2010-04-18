local addonName, ns = ...

local cf
for i = 1, NUM_CHAT_WINDOWS do
	cf = _G["ChatFrame"..i]

	cf:EnableMouseWheel(true)
	cf:SetScript("OnMouseWheel", function(frame, delta)
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
	end)
end

