local _G = _G or getfenv(0)
local GetExpansion = ShaguTweaks.GetExpansion
local UnitCastingInfo = ShaguTweaks.UnitCastingInfo
local UnitChannelInfo = ShaguTweaks.UnitChannelInfo

local module = ShaguTweaks:register({
  title = "Enemy Castbars",
  description = "Shows an enemy castbar on target unit frame.",
  enabled = true,
})

local castbar = CreateFrame("StatusBar", nil, TargetFrame)

castbar:SetPoint("TOP", TargetFrame, "BOTTOM", 0, 0)
castbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
castbar:SetStatusBarColor(1, .8, 0, 1)
castbar:SetWidth(120)
castbar:SetHeight(10)

castbar.texture = CreateFrame("Frame", nil, castbar)
castbar.texture:SetPoint("RIGHT", castbar, "LEFT", -4, 0)
castbar.texture:SetHeight(20)
castbar.texture:SetWidth(20)

castbar.texture.icon = castbar.texture:CreateTexture(nil, "BACKGROUND")
castbar.texture.icon:SetPoint("CENTER", 0, 0)
castbar.texture.icon:SetWidth(16)
castbar.texture.icon:SetHeight(16)
castbar.texture:SetBackdrop({
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 8, edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 }
})

castbar.bg = castbar:CreateTexture(nil, "BACKGROUND")
castbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
castbar.bg:SetVertexColor(.1, .1, 0, .8)
castbar.bg:SetAllPoints(true)

castbar.spark = castbar:CreateTexture(nil, "OVERLAY")
castbar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
castbar.spark:SetWidth(20)
castbar.spark:SetHeight(20)
castbar.spark:SetBlendMode("ADD")

castbar.backdrop = CreateFrame("Frame", nil, castbar)
castbar.backdrop:SetPoint("TOPLEFT", castbar, "TOPLEFT", -3, 3)
castbar.backdrop:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", 3, -3)
castbar.backdrop:SetBackdrop({
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 8, edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 }
})

castbar.text = castbar:CreateFontString(nil, "HIGH", "GameFontWhite")
castbar.text:SetPoint("CENTER", castbar, "CENTER", 0, 0)
local font, size, opts = castbar.text:GetFont()
castbar.text:SetFont(font, size - 2, "THINOUTLINE")

module.enable = function(self)
  local oldUpdate = TargetFrame:GetScript("OnUpdate")
  TargetFrame:SetScript("OnUpdate", function(arg)
    if oldUpdate then oldUpdate(arg) end

    local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(this.unit)
    if not cast then
      -- scan for channel spells if no cast was found
      cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(this.unit)
    end

    if cast then
      local channel = UnitChannelInfo(this.unit)
      local duration = endTime - startTime
      local max = duration / 1000
      local cur = GetTime() - startTime / 1000

      if channel then
        cur = max + startTime/1000 - GetTime()
      end

      cur = cur > max and max or cur
      cur = cur < 0 and 0 or cur

      castbar:Show()
      castbar:SetMinMaxValues(0, duration / 1000)
      castbar:SetValue(cur)

      local percent = cur / max
      local x = castbar:GetWidth()*percent
      castbar.spark:SetPoint("CENTER", castbar, "LEFT", x, 0)

      castbar.text:SetText(cast)

      if texture then
        castbar.texture.icon:SetTexture(texture)
        castbar.texture.icon:Show()
      else
        castbar.texture.icon:Hide()
      end
    else
      castbar:Hide()
    end
  end)
end
