local _G = _G or getfenv(0)
local GetExpansion = ShaguTweaks.GetExpansion
local GetUnitData = ShaguTweaks.GetUnitData

local NAMEPLATE_OBJECTORDER = { "border", "glow", "name", "level", "levelicon", "raidicon" }
if GetExpansion() == "tbc" then
  NAMEPLATE_OBJECTORDER = { "border", "castborder", "casticon", "glow", "name", "level", "levelicon", "raidicon" }
end

local function IsNamePlate(frame)
  if frame:GetObjectType() ~= "Button" then return nil end
  regions = frame:GetRegions()

  if not regions then return nil end
  if not regions.GetObjectType then return nil end
  if not regions.GetTexture then return nil end

  if regions:GetObjectType() ~= "Texture" then return nil end
  return regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" or nil
end

local registry = {}
local initialized = 0
local parentcount, childs, plate
ShaguTweaks.libnameplate = CreateFrame("Frame", nil, UIParent)
ShaguTweaks.libnameplate.OnInit = {}
ShaguTweaks.libnameplate.OnShow = {}
ShaguTweaks.libnameplate.OnUpdate = {}
ShaguTweaks.libnameplate:SetScript("OnUpdate", function()
  parentcount = WorldFrame:GetNumChildren()
  if initialized < parentcount then
    childs = { WorldFrame:GetChildren() }
    for i = initialized + 1, parentcount do
      plate = childs[i]

      if IsNamePlate(plate) and not registry[plate] then
        plate.healthbar = plate:GetChildren()
        for i, object in pairs({plate:GetRegions()}) do
          plate[NAMEPLATE_OBJECTORDER[i]] = object
        end

        -- run OnInit functions
        for id, func in pairs(ShaguTweaks.libnameplate.OnInit) do
          func(plate)
        end

        -- register OnUpdate functions
        local oldUpdate = plate:GetScript("OnUpdate")
        plate:SetScript("OnUpdate", function()
          if oldUpdate then oldUpdate() end
          for id, func in pairs(ShaguTweaks.libnameplate.OnUpdate) do
            func()
          end
        end)

        -- register OnShow functions
        local oldShow = plate:GetScript("OnShow")
        plate:SetScript("OnShow", function()
          if oldShow then oldUpdate() end
          for id, func in pairs(ShaguTweaks.libnameplate.OnShow) do
            func()
          end
        end)

        registry[plate] = plate
      end
    end

    initialized = parentcount
  end
end)
