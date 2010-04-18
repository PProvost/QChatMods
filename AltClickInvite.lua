local addonName, ns = ...

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


