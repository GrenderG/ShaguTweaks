local _G = _G or getfenv(0)
local libdebuff = ShaguTweaks.libdebuff
local module = ShaguTweaks:register({
  title = "Debuff Timer",
  description = "Show debuff durations on the target unit frame.",
  enabled = true,
})

local UnitDebuff = ShaguTweaks.libdebuff.UnitDebuff

local function TimeConvert(remaining)
  local color = "|cffffffff"
  if remaining < 5 then
    color = "|cffff5555"
  elseif remaining < 10 then
    color = "|cffffff55"
  end

  if remaining < 60 then
    return color..ceil(remaining)
  elseif remaining < 3600 then
    return color..ceil(remaining/60).."M"
  elseif remaining < 43200 then
    return color..ceil(remaining/3600).."H"
  else
    return color..ceil(remaining/43200).."D"
  end
end

local function CreateTextCooldown(cooldown)
  if cooldown.readable then return end

  cooldown.readable = CreateFrame("Frame", "pfCooldownFrame", cooldown:GetParent())
  cooldown.readable:SetAllPoints(cooldown)
  cooldown.readable:SetFrameLevel(cooldown:GetParent():GetFrameLevel() + 1)
  cooldown.readable.text = cooldown.readable:CreateFontString("pfCooldownFrameText", "OVERLAY")

  cooldown.readable.text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
  cooldown.readable.text:SetPoint("CENTER", cooldown.readable, "CENTER", 0, 0)
  cooldown.readable:SetScript("OnUpdate", function()
    parent = this:GetParent()
    if not parent then this:Hide() end

    if not this.next then this.next = GetTime() + .1 end
    if this.next > GetTime() then return end
    this.next = GetTime() + .1

    -- fix own alpha value (should be inherited, but somehow isn't always)
    this:SetAlpha(parent:GetAlpha())

    local remaining = this.duration - (GetTime() - this.start)
    if remaining >= 0 then
      this.text:SetText(TimeConvert(remaining))
    else
      this:Hide()
    end
  end)
end

module.enable = function(self)
  local HookTargetDebuffButton_Update = TargetDebuffButton_Update
  TargetDebuffButton_Update = function()
    HookTargetDebuffButton_Update()

    for i=1, MAX_TARGET_DEBUFFS do
      local effect, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff("target", i)
  		local button = _G["TargetFrameDebuff"..i]

      if not button.cd then
        button.cd = CreateFrame("Model", "TargetFrameDebuff"..i.."Cooldown", button, "CooldownFrameTemplate")
        button.cd:SetAllPoints()
        button.cd:SetScale(.6)
        button.cd:SetAlpha(.8)
      end

  		if effect and duration and timeleft then
        local start = GetTime() + timeleft - duration
        CooldownFrame_SetTimer(button.cd, start, duration, 1)
        CreateTextCooldown(button.cd)
        button.cd.readable.start = start
        button.cd.readable.duration = duration
        button.cd.readable:Show()
        button.cd:Show()
      else
        CooldownFrame_SetTimer(button.cd,0,0,0)
      end
  	end
  end
end
