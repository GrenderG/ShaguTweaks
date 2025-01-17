local _G = _G or getfenv(0)
local GetExpansion = ShaguTweaks.GetExpansion

local module = ShaguTweaks:register({
  title = "Equip Compare",
  description = "Shows currently equipped items on tooltips while the shift key is pressed.",
  enabled = true,
})

local itemtypes = {
  ["deDE"] = {
    ["INVTYPE_WAND"] = "Zauberstab",
    ["INVTYPE_THROWN"] = "Wurfwaffe",
    ["INVTYPE_GUN"] = "Schusswaffe",
    ["INVTYPE_CROSSBOW"] = "Armbrust",
    ["INVTYPE_PROJECTILE"] = "Projektil",
  },
  ["enUS"] = {
    ["INVTYPE_WAND"] = "Wand",
    ["INVTYPE_THROWN"] = "Thrown",
    ["INVTYPE_GUN"] = "Gun",
    ["INVTYPE_CROSSBOW"] = "Crossbow",
    ["INVTYPE_PROJECTILE"] = "Projectile",
  },
  ["esES"] = {
    ["INVTYPE_WAND"] = "Varita",
    ["INVTYPE_THROWN"] = "Arma arrojadiza",
    ["INVTYPE_GUN"] = "Arma de fuego",
    ["INVTYPE_CROSSBOW"] = "Ballesta",
    ["INVTYPE_PROJECTILE"] = "Proyectil",
  },
  ["frFR"] = {
    ["INVTYPE_WAND"] = "Baguette",
    ["INVTYPE_THROWN"] = "Armes de jet",
    ["INVTYPE_GUN"] = "Arme à feu",
    ["INVTYPE_CROSSBOW"] = "Arbalète",
    ["INVTYPE_PROJECTILE"] = "Projectile",
  },
  ["koKR"] = {
    ["INVTYPE_WAND"] = "마법봉",
    ["INVTYPE_THROWN"] = "투척 무기",
    ["INVTYPE_GUN"] = "총",
    ["INVTYPE_CROSSBOW"] = "석궁",
    ["INVTYPE_PROJECTILE"] = "투사체",
  },
  ["ruRU"] = {
    ["INVTYPE_WAND"] = "Жезл",
    ["INVTYPE_THROWN"] = "Метательное",
    ["INVTYPE_GUN"] = "Огнестрельное",
    ["INVTYPE_CROSSBOW"] = "Арбалет",
    ["INVTYPE_PROJECTILE"] = "Боеприпасы",
  },
  ["zhCN"] = {
    ["INVTYPE_WAND"] = "魔杖",
    ["INVTYPE_THROWN"] = "投掷武器",
    ["INVTYPE_GUN"] = "枪械",
    ["INVTYPE_CROSSBOW"] = "弩",
    ["INVTYPE_PROJECTILE"] = "弹药",
  }
 }

-- set globals for all inventory types
for key, value in pairs(itemtypes[GetLocale()]) do setglobal(key, value) end
INVTYPE_WEAPON_OTHER = INVTYPE_WEAPON.."_other";
INVTYPE_FINGER_OTHER = INVTYPE_FINGER.."_other";
INVTYPE_TRINKET_OTHER = INVTYPE_TRINKET.."_other";

local slots = {
  [INVTYPE_2HWEAPON] = "MainHandSlot",
  [INVTYPE_BODY] = "ShirtSlot",
  [INVTYPE_CHEST] = "ChestSlot",
  [INVTYPE_CLOAK] = "BackSlot",
  [INVTYPE_FEET] = "FeetSlot",
  [INVTYPE_FINGER] = "Finger0Slot",
  [INVTYPE_FINGER_OTHER] = "Finger1Slot",
  [INVTYPE_HAND] = "HandsSlot",
  [INVTYPE_HEAD] = "HeadSlot",
  [INVTYPE_HOLDABLE] = "SecondaryHandSlot",
  [INVTYPE_LEGS] = "LegsSlot",
  [INVTYPE_NECK] = "NeckSlot",
  [INVTYPE_RANGED] = "RangedSlot",
  [INVTYPE_RELIC] = "RangedSlot",
  [INVTYPE_ROBE] = "ChestSlot",
  [INVTYPE_SHIELD] = "SecondaryHandSlot",
  [INVTYPE_SHOULDER] = "ShoulderSlot",
  [INVTYPE_TABARD] = "TabardSlot",
  [INVTYPE_TRINKET] = "Trinket0Slot",
  [INVTYPE_TRINKET_OTHER] = "Trinket1Slot",
  [INVTYPE_WAIST] = "WaistSlot",
  [INVTYPE_WEAPON] = "MainHandSlot",
  [INVTYPE_WEAPON_OTHER] = "SecondaryHandSlot",
  [INVTYPE_WEAPONMAINHAND] = "MainHandSlot",
  [INVTYPE_WEAPONOFFHAND] = "SecondaryHandSlot",
  [INVTYPE_WRIST] = "WristSlot",
  [INVTYPE_WAND] = "RangedSlot",
  [INVTYPE_GUN] = "RangedSlot",
  [INVTYPE_PROJECTILE] = "AmmoSlot",
  [INVTYPE_CROSSBOW] = "RangedSlot",
  [INVTYPE_THROWN] = "RangedSlot",
}

module.enable = function(self)
  local compare = CreateFrame( "Frame" , nil, GameTooltip )
  compare:SetScript("OnShow", function()
    -- abort if shift is not pressed
    if not IsShiftKeyDown() then return end

    for i=1,GameTooltip:NumLines() do
      local tmpText = _G[GameTooltip:GetName() .. "TextLeft"..i]

      for slotType, slotName in pairs(slots) do
        if tmpText:GetText() == slotType then
          local slotID = GetInventorySlotInfo(slotName)

          -- determine screen part
          local x = GetCursorPosition() / UIParent:GetEffectiveScale()
          local anchor = x < GetScreenWidth() / 2 and "BOTTOMLEFT" or "BOTTOMRIGHT"
          local relative = x < GetScreenWidth() / 2 and "BOTTOMRIGHT" or "BOTTOMLEFT"

          -- first tooltip
          ShoppingTooltip1:SetOwner(GameTooltip, "ANCHOR_NONE");
          ShoppingTooltip1:ClearAllPoints();
          ShoppingTooltip1:SetPoint(anchor, GameTooltip, relative, 0, 0);
          ShoppingTooltip1:SetInventoryItem("player", slotID)
          ShoppingTooltip1:Show()

          -- second tooltip
          if slots[slotType .. "_other"] then
            local slotID_other = GetInventorySlotInfo(slotName)
            ShoppingTooltip2:SetOwner(GameTooltip, "ANCHOR_NONE");
            ShoppingTooltip2:ClearAllPoints();
            ShoppingTooltip2:SetPoint(anchor, ShoppingTooltip1, relative, 0, 0);
            ShoppingTooltip2:SetInventoryItem("player", slotID_other)
            ShoppingTooltip2:Show();
          end
        end
      end
    end
  end)
end
