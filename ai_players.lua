local Card = require("card")

local AI = {
    players = {}
}

function AI.init(cardPool)
    for i = 1, 3 do
        local deck = {}
        for _, cardData in ipairs(cardPool) do
            table.insert(deck, cardData)
            table.insert(deck, cardData)
        end
        for j = #deck, 2, -1 do
            local k = love.math.random(j)
            deck[j], deck[k] = deck[k], deck[j]
        end

        AI.players[i] = {
            deck = deck,
            hand = {},
            mana = 1
        }

        for _ = 1, 3 do
            AI.drawCard(i)
        end
    end
end

function AI.drawCard(aiIndex)
    local ai = AI.players[aiIndex]
    if ai and ai.deck and #ai.deck > 0 and #ai.hand < 7 then
        local data = table.remove(ai.deck)
        local card = Card:new(data[1], data[2], data[3], data[4])
        table.insert(ai.hand, card)
    end
end


function AI.playTurn(locations)
    for aiIndex, ai in ipairs(AI.players) do
        local shuffledLocations = {1, 2, 3}
        for i = #shuffledLocations, 2, -1 do
            local j = love.math.random(i)
            shuffledLocations[i], shuffledLocations[j] = shuffledLocations[j], shuffledLocations[i]
        end

        while ai.mana > 0 do
            local cardPlayed = false

            for locIndex = 1, #shuffledLocations do
                local loc = locations[shuffledLocations[locIndex]]
                local locName = loc.name
                local slotKey = "ai" .. aiIndex .. "Slots"
                if not loc[slotKey] then loc[slotKey] = {} end

                for slot = 1, 4 do
                    local slotTaken = false
                    slotTaken = loc.playerSlots[slot] ~= nil
                    if not slotTaken then
                        for otherIndex = 1, 3 do
                            if loc["ai" .. otherIndex .. "Slots"][slot] then
                                slotTaken = true
                                break
                            end
                        end
                    end


                    if not slotTaken and not loc[slotKey][slot] then
                        for h, card in ipairs(ai.hand) do
                            local restriction = cardRestrictions[card.name]
                            if card.cost <= ai.mana and (restriction == nil or restriction == locName) then
                                loc[slotKey][slot] = card
                                ai.mana = ai.mana - card.cost
                                table.remove(ai.hand, h)
                                cardPlayed = true
                                break
                            end
                        end
                    end

                    if cardPlayed then break end
                end

                if cardPlayed then break end
            end

            if not cardPlayed then break end 
        end
    end
end




function AI.newTurn()
    for i, ai in ipairs(AI.players) do
        ai.mana = ai.mana + 1
        AI.drawCard(i)  
    end
end


return AI
