local _G = _G or getfenv(0)
local GetExpansion = ShaguTweaks.GetExpansion

-- tbc does not allow to rescale nameplates (secure_frames)
if GetExpansion() == "tbc" then return end

local module = ShaguTweaks:register({
  title = "Nameplate Scale",
  description = "Makes all nameplates honor the UI-Scale setting.",
  enabled = true,
})

module.enable = function(self)
  if ShaguPlates then return end

  table.insert(ShaguTweaks.libnameplate.OnInit, function(plate)
    local owidth = plate:GetWidth()
    local oheight = plate:GetHeight()

    -- create new plate
    local new = CreateFrame("Frame", nil, plate)
    plate.new = new

    new:SetScale(UIParent:GetScale())
    new:SetAllPoints(plate)
    new.plate = plate

    plate.healthbar:SetParent(new)
    plate.healthbar:SetFrameLevel(1)

    plate:SetWidth(owidth*UIParent:GetScale())
    plate:SetHeight(oheight*UIParent:GetScale())

    for i, object in pairs({plate:GetRegions()}) do
      object:SetParent(new)
    end

    new:SetScript("OnShow", function()
      -- adjust sizes
      this:SetScale(UIParent:GetScale())
      this.plate:SetWidth(owidth*UIParent:GetScale())
      this.plate:SetHeight(oheight*UIParent:GetScale())
    end)
  end)

  table.insert(ShaguTweaks.libnameplate.OnUpdate, function()
    this.new:SetAlpha(this:GetAlpha())
  end)
end
