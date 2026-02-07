--------------------------------------------------
-- Account Played Minimap Button
--------------------------------------------------

-- Addon namespace
AccountPlayed = AccountPlayed or {}
local AP = AccountPlayed

local BUTTON_NAME = "AccountPlayed_MinimapButton"

-- SavedVariables for minimap button
AccountPlayedMinimapDB = AccountPlayedMinimapDB or {
    angle = 225,
    hide = false,
}

-- Localization
local L = {
    TOOLTIP_TITLE = "Account Played",
    TOOLTIP_CLICK = "Left Click: Toggle window",
    TOOLTIP_DRAG = "Drag: Move icon",
}

--------------------------------------------------
-- Positioning (based on LibDBIcon)
--------------------------------------------------

local function UpdateButtonPosition(button)
    local angle = math.rad(AccountPlayedMinimapDB.angle or 225)
    local x, y, q = math.cos(angle), math.sin(angle), 1
    
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end
    
    -- Standard radius for round minimaps
    local radius = 105
    x, y = x * radius, y * radius
    
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

--------------------------------------------------
-- Drag position update (defined once to avoid memory leak)
--------------------------------------------------

local function UpdateDragPosition(self)
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    cx, cy = cx / scale, cy / scale
    local angle = math.deg(math.atan2(cy - my, cx - mx)) % 360
    AccountPlayedMinimapDB.angle = angle
    UpdateButtonPosition(self)
end

--------------------------------------------------
-- Creation
--------------------------------------------------

local function CreateMinimapButton()
    -- Don't create if hidden
    if AccountPlayedMinimapDB.hide then
        return
    end
    
    -- Update position if already exists
    if _G[BUTTON_NAME] then
        UpdateButtonPosition(_G[BUTTON_NAME])
        return
    end
    
    local btn = CreateFrame("Button", BUTTON_NAME, Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:EnableMouse(true)
    btn:RegisterForClicks("LeftButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetClampedToScreen(true)
    
    --------------------------------------------------
    -- Border (OVERLAY, positioned first)
    --------------------------------------------------
    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetSize(53, 53)
    btn.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    btn.border:SetPoint("TOPLEFT")
    
    --------------------------------------------------
    -- Icon (ARTWORK layer, smaller size)
    --------------------------------------------------
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(17, 17)
    btn.icon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
    btn.icon:SetPoint("CENTER")
    btn.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    
    --------------------------------------------------
    -- Highlight
    --------------------------------------------------
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    
    --------------------------------------------------
    -- Tooltip
    --------------------------------------------------
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(L.TOOLTIP_TITLE, 1, 1, 1)
        GameTooltip:AddLine(L.TOOLTIP_CLICK, 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L.TOOLTIP_DRAG, 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    --------------------------------------------------
    -- Click with sound feedback
    --------------------------------------------------
    btn:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        SlashCmdList.ACCOUNTPLAYEDPOPUP()
    end)
    
    --------------------------------------------------
    -- Drag handlers
    --------------------------------------------------
    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", UpdateDragPosition)
    end)
    
    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    
    UpdateButtonPosition(btn)
end

--------------------------------------------------
-- Init
--------------------------------------------------

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    CreateMinimapButton()
end)
