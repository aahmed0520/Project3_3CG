local Card = require("card")
local AI = require("ai_players")

cardRestrictions = {
    Zeus = "Mount Olympus",
    Athena = "Mount Olympus",
    Ares = "Mount Olympus",
    Titan = nil,
    Medusa = "Underworld",
    Poseidon = "Aegean Sea",
    Artemis = "Aegean Sea",
    Hera = "Mount Olympus",
    Apollo = nil,
    Hephaestus = nil,
    Hades = "Underworld"
}

cardPool = {
    { "Zeus", 3, 4, "When Revealed: Lower enemy hand power by 1" },
    { "Athena", 2, 3, "Gain +1 power when another card is played here" },
    { "Titan", 6, 12, "Vanilla" },
    { "Ares", 3, 5, "When Revealed: Gain +2 power for each enemy card here." },
    { "Medusa", 4, 4, "When ANY other card is played here, lower that card's power by 1." },
    { "Poseidon", 4, 6, "When Revealed: Move away an enemy card here with the lowest power." },
    { "Artemis", 2, 2, "When Revealed: Gain +5 power if there is exactly one enemy card here." },
    { "Hera", 3, 3, "When Revealed: Give cards in your hand +1 power." },
    { "Apollo", 1, 2, "When Revealed: Gain +1 mana next turn." },
    { "Hephaestus", 2, 2, "When Revealed: Lower the cost of 2 cards in your hand by 1." },
    { "Hades", 3, 4, "When Revealed: Gain +2 power for each card in your discard pile" }
}

function buildDeck()
    local deck = {}
    for _, cardData in ipairs(cardPool) do
        table.insert(deck, cardData)
        table.insert(deck, cardData)
    end
    for i = #deck, 2, -1 do
        local j = love.math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    return deck
end

function drawCard()
    if #playerDeck > 0 and #playerHand < 7 then
        local data = table.remove(playerDeck)
        local card = Card:new(data[1], data[2], data[3], data[4])
        table.insert(playerHand, card)
        updateHandLayout()
    end
end

function updateHandLayout()
    for index, card in ipairs(playerHand) do
        card.x = 50 + ((index - 1) % 5) * 180
        card.y = 400 + math.floor((index - 1) / 5) * 240
    end
end


function love.load()
    love.window.setTitle("Mythos Arena")
    font = love.graphics.newFont(16)
    love.graphics.setFont(font)

    restartGame()
end

function restartGame()
    turn = 1
    playerMana = turn
    playerScore = 0
    aiScores = { AI1 = 0, AI2 = 0, AI3 = 0 }

    playerDeck = buildDeck()
    playerHand = {}
    selectedCard = nil
    showResultTimer = nil
    turnEnded = false
    winner = nil

    submitButton = { x = 650, y = 20, w = 120, h = 40 }
    restartButton = { x = 320, y = 360, w = 160, h = 50 }

    locations = {
        { name = "Mount Olympus", playerSlots = {}, ai1Slots = {}, ai2Slots = {}, ai3Slots = {} },
        { name = "Underworld", playerSlots = {}, ai1Slots = {}, ai2Slots = {}, ai3Slots = {} },
        { name = "Aegean Sea", playerSlots = {}, ai1Slots = {}, ai2Slots = {}, ai3Slots = {} }
    }

    locationBox = {
        x = 50,
        y = 80,
        width = 700,
        height = 80,
        spacing = 100
    }

    drawCard()
    drawCard()
    drawCard()

    AI.init(cardPool)
end

function love.update(dt)
    if winner then return end

    if selectedCard then
        selectedCard.x = love.mouse.getX() - selectedCard.dragOffsetX
        selectedCard.y = love.mouse.getY() - selectedCard.dragOffsetY
    end

    if turnEnded and showResultTimer then
        showResultTimer = showResultTimer - dt
        if showResultTimer <= 0 then
            for _, loc in ipairs(locations) do
                loc.playerSlots = {}
                loc.ai1Slots = {}
                loc.ai2Slots = {}
                loc.ai3Slots = {}
                loc.combatResult = nil
            end

            turn = turn + 1
            playerMana = turn
            drawCard()
            AI.newTurn()
            turnEnded = false
            showResultTimer = nil
        end
    end
end

function love.draw()
    love.graphics.print("Turn: " .. turn .. " | Mana: " .. playerMana, 20, 20)
    love.graphics.print("Player Score: " .. playerScore, 250, 20)
    love.graphics.print("AI1: " .. aiScores.AI1 .. " | AI2: " .. aiScores.AI2 .. " | AI3: " .. aiScores.AI3, 450, 20)

    love.graphics.setColor(0.3, 0.6, 0.3)
    love.graphics.rectangle("fill", submitButton.x, submitButton.y, submitButton.w, submitButton.h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Submit", submitButton.x, submitButton.y + 10, submitButton.w, "center")

    for i, loc in ipairs(locations) do
        local lx = locationBox.x
        local ly = locationBox.y + (i - 1) * locationBox.spacing
        local totalSlots = 4
        local slotSpacing = 80
        local rowWidth = (totalSlots - 1) * slotSpacing
        local startX = lx + (locationBox.width - rowWidth) / 2

        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("line", lx, ly, locationBox.width, locationBox.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(loc.name, lx + 10, ly + 5)

        for slot = 1, totalSlots do
            local offset = 0
            for aiKey = 1, 3 do
                local card = loc["ai" .. aiKey .. "Slots"][slot]
                if card then
                    local slotX = startX + (slot - 1) * slotSpacing
                    local slotY = ly + 25 
                    card:draw(slotX, slotY, 0.4)
                    offset = offset + 20
                end
            end
        end

        for j = 1, totalSlots do
            local slotX = startX + (j - 1) * slotSpacing
            local slotY = ly + 25
            local playerEmpty = not loc.playerSlots[j]
            local ai1Empty = not loc.ai1Slots[j]
            local ai2Empty = not loc.ai2Slots[j]
            local ai3Empty = not loc.ai3Slots[j]

            if playerEmpty and ai1Empty and ai2Empty and ai3Empty then
                love.graphics.rectangle("line", slotX, slotY, 40, 50)
            end
        end

        for s, card in ipairs(loc.playerSlots) do
            local slotX = startX + (s - 1) * slotSpacing
            local slotY = ly + 25
            card:draw(slotX, slotY, 0.4)
        end

        if loc.combatResult then
            local result = loc.combatResult
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("P: " .. result.player .. " | AI1: " .. result.ai1 .. " | AI2: " .. result.ai2 ,
                lx + locationBox.width - 160, ly + 25)
            love.graphics.print(" | AI3: " .. result.ai3 .. " → " .. result.winner,
                lx + locationBox.width - 160, ly + 50)
            love.graphics.setColor(1, 1, 1)
        end
    end

    for _, card in ipairs(playerHand) do
        if not selectedCard or selectedCard ~= card then
            card:draw(card.x, card.y, 1.0)
        end
    end

    if selectedCard then
        selectedCard:draw(selectedCard.x, selectedCard.y, 1.0)
    end

    if winner then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.printf(winner .. " Wins!", 0, 200, love.graphics.getWidth(), "center")

        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.rectangle("fill", restartButton.x, restartButton.y, restartButton.w, restartButton.h)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("Restart", restartButton.x, restartButton.y + 15, restartButton.w, "center")
    end
end


function love.mousepressed(x, y, button)
    if button == 1 then
        if winner then
            if x >= restartButton.x and x <= restartButton.x + restartButton.w and
               y >= restartButton.y and y <= restartButton.y + restartButton.h then
                restartGame()
            end
            return
        end

        for _, card in ipairs(playerHand) do
            if card:isMouseOver(x, y) then
                selectedCard = card
                card.dragOffsetX = x - card.x
                card.dragOffsetY = y - card.y
                card.originalX = card.x
                card.originalY = card.y
                return
            end
        end

        if x >= submitButton.x and x <= submitButton.x + submitButton.w and
           y >= submitButton.y and y <= submitButton.y + submitButton.h then
            processTurn()
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and selectedCard and not winner then
        local placed = false
        for i, loc in ipairs(locations) do
            local lx = locationBox.x
            local ly = locationBox.y + (i - 1) * locationBox.spacing
            for j = 1, 4 do
                local slotX = lx + 120 + (j - 1) * 60
                local slotY = ly + 25
                local slotW, slotH = 40, 50
                if x >= slotX and x <= slotX + slotW and
                   y >= slotY and y <= slotY + slotH and
                   #loc.playerSlots < 4 and playerMana >= selectedCard.cost then

                    local restriction = cardRestrictions[selectedCard.name]
                    if restriction == nil or restriction == loc.name then
                        selectedCard.x = slotX
                        selectedCard.y = slotY
                        table.insert(loc.playerSlots, selectedCard)

                        for h = #playerHand, 1, -1 do
                            if playerHand[h] == selectedCard then
                                table.remove(playerHand, h)
                                updateHandLayout()
                                break
                            end
                        end

                        playerMana = playerMana - selectedCard.cost
                        placed = true
                    end
                    break
                end
            end
            if placed then break end
        end

        if not placed then
            selectedCard.x = selectedCard.originalX
            selectedCard.y = selectedCard.originalY
        end

        selectedCard = nil
    end
end

function processTurn()
    if winner or turnEnded then return end

    AI.playTurn(locations)

    for _, loc in ipairs(locations) do
        resolveLocationCombat(loc)
    end

    turnEnded = true
    showResultTimer = 2
end

function resolveLocationCombat(loc)
    local playerPower = 0
    for _, card in ipairs(loc.playerSlots) do
        playerPower = playerPower + card.power
    end

    local aiPowers = {}
    for i = 1, 3 do
        local power = 0
        for _, card in ipairs(loc["ai" .. i .. "Slots"]) do
            power = power + card.power
        end
        aiPowers[i] = power
    end

    local maxPower = playerPower
    local win = "Player"
    for i = 1, 3 do
        if aiPowers[i] > maxPower then
            maxPower = aiPowers[i]
            win = "AI" .. i
        elseif aiPowers[i] == maxPower and win ~= "Player" then
            win = "Tie"
        end
    end

    loc.combatResult = {
        player = playerPower,
        ai1 = aiPowers[1],
        ai2 = aiPowers[2],
        ai3 = aiPowers[3],
        winner = win
    }

    if win == "Player" then
        playerScore = playerScore + (playerPower - math.max(aiPowers[1], aiPowers[2], aiPowers[3]))
    elseif win:match("^AI%d$") then
        aiScores[win] = aiScores[win] + (aiPowers[tonumber(win:sub(3))] - playerPower)
    end

    if playerScore >= 20 then
        winner = "Player"
    elseif aiScores.AI1 >= 20 then
        winner = "AI 1"
    elseif aiScores.AI2 >= 20 then
        winner = "AI 2"
    elseif aiScores.AI3 >= 20 then
        winner = "AI 3"
    end
end
