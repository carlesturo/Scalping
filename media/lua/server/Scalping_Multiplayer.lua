-- From "Scalping" mod -- Author = carlesturo

-- **************** SCALPING MULTIPLAYER ****************

local function UpdateCorpseServer(player, args)
    local corpse = getWorld():getCorpseByID(args.corpseId)
    
    if corpse then
        corpse:getModData().hasBeenScalped = true
        corpse:getHumanVisual():setHairModel("Bald")
        
		local corpseContainer = corpse:getContainer()
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

        corpse:transmitHumanVisual()
        corpse:transmitModData()
        sendServerCommand("playSoundForEveryone", { sound = "Chopup", x = corpse:getX(), y = corpse:getY(), z = corpse:getZ() })
    end
end

Events.OnClientCommand.Add(function(module, command, player, args)
    if module == "Scalping" and command == "UpdateCorpseServer" then
        UpdateCorpseServer(player, args)
    end
end)

