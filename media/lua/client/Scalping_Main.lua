-- From "HarvestZ's Cannibalism" mod -- Author = Arendameth
-- Modified by carlesturo

-- **************** SCALPING ****************

Scalping = Scalping or {}

function Scalping.onScalping(playerNum, corpse, knife)
    local character = getSpecificPlayer(playerNum)
    if luautils.walkAdj(character, corpse:getSquare()) then
        ISInventoryPaneContextMenu.transferIfNeeded(character, knife)
        ISTimedActionQueue.add(ISEquipWeaponAction:new(character, knife, 10, true, true))
        ISTimedActionQueue.add(Scalping_Scalping:new(character, corpse, knife))
    end
end

local function KeyRingDataWithPlayerName(player)
    if not instanceof(player, "IsoPlayer") then return end
    local keyRing = player:getInventory():FindAndReturn("KeyRing")
    if keyRing then
        keyRing:getModData().playerName = player:getFullName()
    else
        local clip = InventoryItemFactory.CreateItem("Paperclip")
        clip:getModData().playerName = player:getFullName()
        player:getInventory():AddItem(clip)
    end
end

local function OnPlayerDeath(player)
    KeyRingDataWithPlayerName(player)
end

Events.OnCharacterDeath.Add(OnPlayerDeath)

function TransferKeyRingDataToCorpse(corpse)
    if not corpse then return end
    local corpseContainer = corpse:getContainer()
    if not corpseContainer then return end
    local keyRing = corpseContainer:FindAndReturn("KeyRing")
    if keyRing then
        local keyRingModData = keyRing:getModData()
        if keyRingModData.playerName then
            corpse:getModData().playerName = keyRingModData.playerName
            keyRing:getModData().playerName = nil
            return
        end
    end

    local paperclip = corpseContainer:FindAndReturn("Paperclip")
    if paperclip then
        local paperclipModData = paperclip:getModData()
        if paperclipModData.playerName then
            corpse:getModData().playerName = paperclipModData.playerName
        end
        corpseContainer:Remove(paperclip)
    end
end

-- **************** SCALPING CONTEXT MENU ****************

local _ISWorldObjectContextMenu_createMenu = ISWorldObjectContextMenu.createMenu
ISWorldObjectContextMenu.createMenu = function(player, worldobjects, x, y, test)
    local context = _ISWorldObjectContextMenu_createMenu(player, worldobjects, x, y, test)

    ---@type IsoDeadBody
    if body then
        local knife = Scalping.getKnife(player)
        local option = context:addOption(getText("ContextMenu_ScalpingTheCorpse"), player, Scalping.onScalping, body, knife)
        local description = getText("ContextMenu_Description_ScalpingTheCorpseToObtainTheTrophy")
        if body:getModData().hasBeenScalped then
            option.notAvailable = true
            description = "<RED>" .. getText("ContextMenu_Description_ItHasAlreadyBeenDone")
        elseif not knife then
            option.notAvailable = true
            description = "<RED>" .. getText("ContextMenu_Description_RequiresASharpTool")
        end
        local tooltip = ISToolTip:new()
        tooltip:initialise()
        tooltip:setVisible(false)
        tooltip.description = description
        option.toolTip = tooltip
    end
    
    return context
end