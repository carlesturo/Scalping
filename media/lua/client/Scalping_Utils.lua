-- From "HarvestZ's Cannibalism" mod -- Author = Arendameth
-- Modified by carlesturo

-- **************** SCALPING ****************

Scalping = Scalping or {}

function Scalping.getKnife(playerNum)
    local character = getSpecificPlayer(playerNum)
    if character then
        local inventory = character:getInventory()
        local knife = inventory:getFirstTypeRecurse("MeatCleaver")
            or inventory:getFirstTagRecurse("ChopTree")
            or inventory:getFirstTagRecurse("SharpKnife")
            or inventory:getFirstTypeRecurse("Chainsaw")
            or inventory:getFirstTagRecurse("Saw")

        if knife and knife:isBroken() then
            knife = nil
        end

        return knife
    end
end