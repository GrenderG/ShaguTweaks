local _G = _G or getfenv(0)
local GetExpansion = ShaguTweaks.GetExpansion

local module = ShaguTweaks:register({
  title = "Unit Frame Class Colors",
  description = "Adds class colors to the player, target and party unit frames.",
  enabled = nil,
})

local partycolors = function()
  for id = 1, MAX_PARTY_MEMBERS do
    local name = _G['PartyMemberFrame'..id..'Name']
    local _, class = UnitClass("party" .. id)
    local class = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }
    name:SetTextColor(class.r, class.g, class.b, 1)
  end
end

module.enable = function(self)
  -- enable class color backgrounds
  local original = TargetFrame_CheckFaction
  function TargetFrame_CheckFaction(self)
    original(self)

    local reaction = UnitReaction("target", "player")

	  if UnitPlayerControlled("target") then
	    local _, class = UnitClass("target")
	    local class = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }
	    TargetFrameNameBackground:SetVertexColor(class.r, class.g, class.b, 1)
	    TargetFrameNameBackground:Show()
 	    TargetFrameBackground:Hide()
	  elseif reaction and reaction > 4 then
	    TargetFrameNameBackground:Hide()
	    TargetFrameBackground:Show()
    else
	    TargetFrameNameBackground:Show()
	    TargetFrameBackground:Hide()
    end
  end

  local _, class = UnitClass("player")
  local class = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }

  -- add name background to player frame
  PlayerFrameNameBackground = PlayerFrame:CreateTexture(nil, "BACKGROUND")
  PlayerFrameNameBackground:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
  PlayerFrameNameBackground:SetWidth(119)
  PlayerFrameNameBackground:SetHeight(19)
  PlayerFrameNameBackground:SetPoint("TOPLEFT", 106, -22)
  PlayerFrameNameBackground:SetVertexColor(class.r, class.g, class.b, 1)
  PlayerFrameBackground:Hide()

  local wait = CreateFrame("Frame")
  wait:RegisterEvent("PLAYER_ENTERING_WORLD")
  wait:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    local class = RAID_CLASS_COLORS[class] or { r = .5, g = .5, b = .5, a = 1 }
    PlayerFrameNameBackground:SetVertexColor(class.r, class.g, class.b, 1)
    this:UnregisterAllEvents()
  end)

  -- add font outline
  local font, size = PlayerFrame.name:GetFont()
  PlayerFrame.name:SetFont(font, size, "NONE")
  TargetFrame.name:SetFont(font, size, "NONE")

  -- add party frame class colors
  local HookPartyMemberFrame_UpdateMember = PartyMemberFrame_UpdateMember
  PartyMemberFrame_UpdateMember = function(self)
    HookPartyMemberFrame_UpdateMember(self)
    partycolors()
  end

  partycolors()
end
