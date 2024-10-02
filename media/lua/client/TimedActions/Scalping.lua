-- From "HarvestZ's Cannibalism" mod -- Author = Arendameth
-- Modified by carlesturo

-- **************** SCALPING ****************

require "TimedActions/ISBaseTimedAction"
Scalping_Scalping = ISBaseTimedAction:derive("Scalping_Scalping");

function Scalping_Scalping:isValid()
    if not self.corpse then return false; end
    if not self.corpse:getSquare() then return false; end
    if self.corpse:getModData().hasBeenScalped then return false; end
    if not self.character:getInventory():contains(self.knife) then return false; end
    return true;
end

function Scalping_Scalping:update()
    self.character:faceThisObject(self.corpse);
	self.knife:setJobDelta(self:getJobDelta());
end

function Scalping_Scalping:waitToStart()
    self.character:faceThisObject(self.corpse);
    return self.character:shouldBeTurning();
end

function Scalping_Scalping:start()
    self:setActionAnim("SawLog");
    self:setOverrideHandModels(self.character:getPrimaryHandItem(), nil);
	self.knife:setJobType(getText("ContextMenu_ScalpingTheCorpse"));
    self.knife:setJobDelta(0.0);
    self.sound = self.character:getEmitter():playSound("Chopup");
end

function Scalping_Scalping:stop()
	self.knife:setJobDelta(0.0);
    self.character:getEmitter():stopSound(self.sound);
    ISBaseTimedAction.stop(self);
end

function Scalping_Scalping:perform()
    self.corpse:getModData().hasBeenScalped = true
    local originalHairColor = self.corpse:getHumanVisual():getHairColor()
    self.corpse:getHumanVisual():setHairModel("Bald")
    TransferKeyRingDataToCorpse(self.corpse)
	
    local corpseContainer = self.corpse:getContainer()
    local patternsPrimary, patternsSecondary

    if self.corpse:isZombie() then
        patternsPrimary = {"^Underpants_", "^Frilly", "^Bra_", "^Briefs_", "^Boxers_"}
        patternsSecondary = {"^Socks_", "^WristWatch_"}
    elseif self.corpse:getHumanVisual():isFemale() then
        patternsPrimary = {"^Underpants_", "^Frilly", "^Bra_", "^Briefs_", "^Boxers_"}
        patternsSecondary = {"^Socks_", "^WristWatch_"}
    else
        patternsPrimary = {"^Underpants_", "^Frilly", "^Bra_", "^Briefs_", "^Boxers_"}
        patternsSecondary = {"^Socks_", "^WristWatch_"}
    end

    local itemFound = false
    for i = corpseContainer:getItems():size() - 1, 0, -1 do
        local item = corpseContainer:getItems():get(i)
        for _, pattern in ipairs(patternsPrimary) do
            if string.match(item:getType(), pattern) then
                corpseContainer:Remove(item)
                corpseContainer:AddItem(item)
                itemFound = true
                break
            end
        end
        if itemFound then break end
    end

    if not itemFound then
        for i = corpseContainer:getItems():size() - 1, 0, -1 do
            local item = corpseContainer:getItems():get(i)
            for _, pattern in ipairs(patternsSecondary) do
                if string.match(item:getType(), pattern) then
                    corpseContainer:Remove(item)
                    corpseContainer:AddItem(item)
                    itemFound = true
                    break
                end
            end
            if itemFound then break end
        end
    end

    local scalp = InventoryItemFactory.CreateItem("Scalp")
    scalp:getModData().originalHairColor = {
        r = originalHairColor:getRedFloat(),
        g = originalHairColor:getGreenFloat(),
        b = originalHairColor:getBlueFloat()
    }

    local color = ImmutableColor.new(originalHairColor:getRedFloat(), originalHairColor:getGreenFloat(), originalHairColor:getBlueFloat(), 1.0)
    scalp:getVisual():setTint(color)

    local playerName = self.corpse:getModData().playerName
    local scalpTitle

	if self.corpse:isZombie() then
		if playerName then
			scalpTitle = getText("IGUI_ZombieTrophyOf", playerName)
		else
			scalpTitle = getText("IGUI_ZombieTrophy")
		end
	else
		if playerName then
			scalpTitle = getText("IGUI_HumanTrophyOf", playerName)
		else
			scalpTitle = scalp:getDisplayName()
		end
	end

    scalp:setName(scalpTitle)
    self.character:getInventory():AddItem(scalp)
	
	sendClientCommand(self.character, "Scalping", "UpdateCorpseServer", { corpseId = self.corpse:getId() })
	
    self.character:getEmitter():stopSound(self.sound);
	self.knife:setJobDelta(0.0);
    ISBaseTimedAction.perform(self);
end

function Scalping_Scalping:new(character, corpse, knife)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.corpse = corpse;
    o.knife = knife;
    o.maxTime = 48 * 10; -- Time taken by the action (48 per 1 second)
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o
end