import SpriteKit

class Board: SKNode {
    
    // MARK: - Properties
    
    // Tracks how many cards are currently in each column
    var columnCounts: [String: Int] = [:]
    
    // We need to store the size so the board knows how big to draw itself
    private let boardSize: CGSize
    
    var hermit: Hermit
    var gameDeck: Deck!
    var moveCounter: Int = 0
    var goldLabel: SKLabelNode?
    
    // MARK: - Initialization
    
    init(size: CGSize, hermit: Hermit) {
        self.boardSize = size
        self.hermit = hermit
        super.init()
        
        // Calculate the card size FIRST so we can build the deck
        let gap: CGFloat = 4.0
        let topHeight = size.height * 0.20
        let bottomHeight = size.height * 0.20
        let middleHeight = size.height - topHeight - bottomHeight - (gap * 2)
        let colWidth = (size.width - (gap * 3)) / 4
        
        let cardWidth = colWidth * 0.85
        
        let singleCellHeight = middleHeight / 4.0
        let maxSafeHeight = singleCellHeight * 0.90 // Guarantees a 10% gap between cards
        let finalCardHeight = min(cardWidth * 1.4, maxSafeHeight)
        let calculatedCardSize = CGSize(width: cardWidth, height: finalCardHeight)
        
        // Build the Deck with the perfect size!
        self.gameDeck = Deck(hermit: self.hermit, cardSize: calculatedCardSize)
        
        createBoardLayout()
        placeHermitInBottomRow()
        createSellLabel()
        setupInitialLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Generation
    
    private func setupInitialLayout() {
        let startingDistribution = [1, 2, 3, 1]
        var delay: TimeInterval = 0.0 // Start with no delay
        
        for (colIndex, count) in startingDistribution.enumerated() {
            let nodeName = "Middle_Col_\(colIndex)"
            
            if let targetColumn = self.childNode(withName: nodeName) as? SKSpriteNode {
                for _ in 0..<count {
                    
                    // Create a delayed action for each card
                    let wait = SKAction.wait(forDuration: delay)
                    let spawn = SKAction.run { [weak self] in
                        self?.spawnCard(in: targetColumn)
                    }
                    
                    // Run the sequence on the board
                    self.run(SKAction.sequence([wait, spawn]))
                    
                    // Add 0.15 seconds to the clock for the NEXT card
                    delay += 0.15
                }
            }
        }
        
        let finalWait = SKAction.wait(forDuration: delay + 0.2)
        let reveal = SKAction.run { [weak self] in
            self?.revealBottomCards()
        }
        self.run(SKAction.sequence([finalWait, reveal]))
    }
    
    private func createBoardLayout() {
        let screenWidth = boardSize.width
        let screenHeight = boardSize.height
        let gap: CGFloat = 4.0
        
        let topHeight = screenHeight * 0.20
        let bottomHeight = screenHeight * 0.20
        let middleHeight = screenHeight - topHeight - bottomHeight - (gap * 2)
        let colWidth = (screenWidth - (gap * 3)) / 4
        
        // Build the Top Header
        let topNode = SKSpriteNode(color: .darkGray, size: CGSize(width: screenWidth, height: topHeight))
        topNode.name = "TopHeader"
        topNode.anchorPoint = .zero
        topNode.position = CGPoint(x: 0, y: screenHeight - topHeight)
        addChild(topNode)
        
        // Build Middle Row
        let middleY = bottomHeight + gap
        generateRow(yPosition: middleY, height: middleHeight, colWidth: colWidth, gap: gap, color: .gray, rowName: "Middle")
        
        // Build Bottom Row
        let bottomY: CGFloat = 0.0
        generateRow(yPosition: bottomY, height: bottomHeight, colWidth: colWidth, gap: gap, color: .lightGray, rowName: "Bottom")
    }
    
    private func generateRow(yPosition: CGFloat, height: CGFloat, colWidth: CGFloat, gap: CGFloat, color: UIColor, rowName: String) {
        for i in 0..<4 {
            let cell = SKSpriteNode(color: color, size: CGSize(width: colWidth, height: height))
            cell.name = "\(rowName)_Col_\(i)"
            cell.anchorPoint = .zero
            
            let xPos = (CGFloat(i) * colWidth) + (CGFloat(i) * gap)
            cell.position = CGPoint(x: xPos, y: yPosition)
            addChild(cell)
        }
    }
    
    private func placeHermitInBottomRow() {
        if let hermitSlot = self.childNode(withName: "Bottom_Col_1") as? SKSpriteNode {
            hermit.position = CGPoint(x: hermitSlot.frame.midX, y: hermitSlot.frame.midY)
            hermit.zPosition = 50
            self.addChild(hermit)
        }
    }
    
    private func createSellLabel() {
        if let topHeader = self.childNode(withName: "TopHeader") as? SKSpriteNode {
            let goldDisplay = SKLabelNode(text: "Gold: \(self.hermit.gold)")
            goldDisplay.fontSize = 24
            goldDisplay.fontName = "Helvetica-Bold"
            goldDisplay.fontColor = .systemYellow
            goldDisplay.horizontalAlignmentMode = .right
            
            // --- THE FIX: Calculate the right edge based on the center anchor ---
            let rightEdgeX = topHeader.size.width - 20
            
            // Note: If you want it dead center vertically inside the header, Y should just be 0.
            // If you still need your custom offset, just swap '0' back to 'headerCenterY - 8'
            goldDisplay.position = CGPoint(x: rightEdgeX, y: 10)
            goldDisplay.zPosition = 10
            
            topHeader.addChild(goldDisplay)
            self.goldLabel = goldDisplay
        }
    }
    
    // MARK: - Core Game Logic
    
    // The Router: Figures out where the card is going and hands it to the right function
    func appendCard(_ card: Card, toSlot slotName: String) -> Bool {
        // Enforce 4-card cap on manual drops
        if slotName.hasPrefix("Middle_Col_") {
            let count = columnCounts[slotName, default: 0]
            if count >= 4 {
                print("❌ Column is full! Cannot drop here.")
                return false // Reject the drop
            }
            
            removeFromOldSlot(card)
            dropOnMiddleColumn(card, slotName: slotName)
            
        } else if slotName.hasPrefix("Bottom_Col_") {
            removeFromOldSlot(card)
            appendToBottomRow(card, slotName: slotName)
            
        } else {
            return false
        }
        
        return true
    }
    
    func registerMove() {
        tickCooldowns()
        moveCounter += 1
        print("Moves: \(moveCounter)/3")
        
        if moveCounter >= 3 {
            moveCounter = 0
            print("🃏 Auto-Dealing new row!")
            
            // Wait 0.3 seconds so the user's drop animation finishes before the new cards fly in
            let wait = SKAction.wait(forDuration: 0.3)
            let deal = SKAction.run { [weak self] in
                self?.dealOneCardToAllColumns()
                
                self?.revealBottomCards()
            }
            self.run(SKAction.sequence([wait, deal]))
        }
    }
    
    // MARK: - Economy
        
    func sellCard(_ card: Card) -> Bool {
        let value = card.rank.value
        
        // 1. Give the actual data (money) to the Hermit
        self.hermit.addGold(amount: value)
        
        // 2. Update the Global UI label on the Top Bar!
        self.goldLabel?.text = "Gold: \(self.hermit.gold)"
        
        print("💰 Sold card for \(value) gold! Hermit total: \(self.hermit.gold)")
        
        removeFromOldSlot(card)
        
        // 3. Run the visual animation
        if let header = self.childNode(withName: "TopHeader") {
            let flyToTop = SKAction.move(to: CGPoint(x: header.frame.midX, y: header.frame.midY), duration: 0.2)
            let vanish = SKAction.group([SKAction.scale(to: 0.1, duration: 0.2), SKAction.fadeOut(withDuration: 0.2)])
            card.run(SKAction.sequence([flyToTop, vanish, SKAction.removeFromParent()]))
        }
        
        registerMove()
        return true
    }
    
    // MARK: - Spawning & Dealing
    
    func dealOneCardToAllColumns() {
        for i in 0..<4 {
            let nodeName = "Middle_Col_\(i)"
            if let targetColumn = self.childNode(withName: nodeName) as? SKSpriteNode {
                spawnCard(in: targetColumn)
            }
        }
    }
    
    // Spawning a card pulls it and hands it to the Conveyor Master
    func spawnCard(in targetColumn: SKSpriteNode) {
        guard !gameDeck.deck.isEmpty else { return }
        let newCard = gameDeck.deck.removeFirst()
        self.addChild(newCard)
        
        dealConveyorToMiddleColumn(newCard, slotName: targetColumn.name ?? "")
    }

    // MARK: - Zone Specific Handlers
        
    private func dropOnMiddleColumn(_ card: Card, slotName: String) {
        guard let slotNode = self.childNode(withName: slotName) as? SKSpriteNode else { return }
        let count = columnCounts[slotName, default: 0]
        
        card.name = "\(slotName)_Card_\(count)"
        card.currentSlotName = slotName
        
        let slotCenterX = slotNode.position.x + (slotNode.size.width / 2.0)
                
        // --- 2. The Strict Vertical Grid ---
        // Instead of using the card's height, we divide the column perfectly into 4 cells
        let cellHeight = slotNode.size.height / 4.0
        
        // Find the absolute top of the column
        let slotTopY = slotNode.position.y + slotNode.size.height
        
        // Start at the center of the top cell, and move down by one cellHeight per card
        let newY = slotTopY - (cellHeight / 2.0) - (CGFloat(count) * cellHeight)
        
        let snap = SKAction.move(to: CGPoint(x: slotCenterX, y: newY), duration: 0.2)
        card.run(snap)
        
        card.zPosition = 10 + CGFloat(count)
        columnCounts[slotName] = count + 1
    }

    private func appendToBottomRow(_ card: Card, slotName: String) {
        guard let slotNode = self.childNode(withName: slotName) as? SKSpriteNode else { return }
        let count = columnCounts[slotName, default: 0]
        
        card.name = "\(slotName)_Card_\(count)"
        card.currentSlotName = slotName
        
        let yOffset = card.size.height / 3.0
        let slotCenterY = slotNode.position.y + (slotNode.size.height / 2.0)
        let _ = slotNode.position.x + (slotNode.size.width / 2.0)
        
        let newY = slotCenterY - (CGFloat(count) * yOffset)

        let snap = SKAction.move(to: CGPoint(x: slotNode.frame.midX, y: newY), duration: 0.2)
        card.run(snap)
        card.zPosition = 30 + CGFloat(count) // Render on top of the card below it
        
        columnCounts[slotName] = count + 1
    }
    
    private func dealConveyorToMiddleColumn(_ card: Card, slotName: String) {
        guard let slotNode = self.childNode(withName: slotName) as? SKSpriteNode else { return }
        var count = columnCounts[slotName, default: 0]
        
        // --- 1. Trigger effect when pushing off the bottom card ---
        if count >= 4 {
            if let bottomCard = self.childNode(withName: "\(slotName)_Card_3") as? Card {
                print("💥 Conveyor pushed off a card! Triggering effect.")
                
                if (bottomCard.suit == .clubs) {
                    // Make sure you use the updated encapsulation here if you renamed it!
                    bottomCard.triggerEffect(hermit: self.hermit)
                }
                
                let vanish = SKAction.sequence([SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()])
                bottomCard.run(vanish)
            }
            count = 3 // We successfully made room!
        }
        
        // --- THE FIX: Absolute Grid Math ---
        // Force the card to the absolute horizontal center of the column
        let slotCenterX = slotNode.position.x + (slotNode.size.width / 2.0)
        
        // Divide the column perfectly into 4 cells, completely ignoring card size!
        let cellHeight = slotNode.size.height / 4.0
        
        // --- 2. Shift existing cards DOWN ---
        if count > 0 {
            for i in (0..<count).reversed() {
                if let oldCard = self.childNode(withName: "\(slotName)_Card_\(i)") as? Card {
                    oldCard.name = "\(slotName)_Card_\(i + 1)"
                    
                    // Move down by exactly one grid cell
                    let targetY = (slotNode.position.y + slotNode.size.height) - (cellHeight / 2.0) - (CGFloat(i + 1) * cellHeight)
                    let moveDown = SKAction.move(to: CGPoint(x: slotCenterX, y: targetY), duration: 0.2)
                    
                    oldCard.run(moveDown)
                    oldCard.zPosition = 20 - CGFloat(i + 1)
                }
            }
        }
        
        // --- 3. Slot new card at the Top ---
        card.name = "\(slotName)_Card_0"
        card.currentSlotName = slotName
        
        // Find the absolute center of the top cell
        let startY = slotNode.position.y + slotNode.size.height - (cellHeight / 2.0)
        
        let snap = SKAction.move(to: CGPoint(x: slotCenterX, y: startY), duration: 0.2)
        card.run(snap)
        card.zPosition = 20
        
        columnCounts[slotName] = count + 1
    }

    // MARK: - Combat System
    
    func resolveCombat(attacker: Card, defender: Card) -> Bool {
        let attackerValue = attacker.rank.value
        let defenderValue = defender.rank.value

        let newAttackerValue = attackerValue - defenderValue
        let newDefenderValue = defenderValue - attackerValue

        // --- 1. Handle Defender (The Club Enemy) ---
        if newDefenderValue <= 0 {
            print("💀 Enemy destroyed!")
            removeFromOldSlot(defender)
            let vanish = SKAction.sequence([SKAction.scale(to: 0.1, duration: 0.2), SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()])
            defender.run(vanish)
        } else {
            print("🛡️ Enemy survives with \(newDefenderValue) HP!")
            defender.updateRank(to: Rank.from(value: newDefenderValue))
        }

        // --- 2. Handle Attacker (The Spade Weapon) ---
        if newAttackerValue <= 0 {
            print("💥 Weapon broke!")
            removeFromOldSlot(attacker)
            let vanish = SKAction.sequence([SKAction.scale(to: 0.1, duration: 0.2), SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()])
            attacker.run(vanish)
        } else {
            print("🗡️ Weapon survives with \(newAttackerValue) durability!")
            attacker.updateRank(to: Rank.from(value: newAttackerValue))
            
            // Snap the weapon safely back to the Hermit's hand!
            if let snapBackPos = attacker.userData?["startingPosition"] as? CGPoint {
                let snapBack = SKAction.move(to: snapBackPos, duration: 0.2)
                attacker.run(snapBack)
            }
        }
        
        registerMove() // Attacking costs a move!
        return true
    }

    // MARK: - Hearts Logic

    func resolveHeal(healer: Card) -> Bool {
        print("💚 Healing for \(healer.rank.value)!")
        
        healer.triggerEffect(hermit: self.hermit)
        
        // Exhaust the card instead of destroying it
        healer.isExhausted = true
        healer.movesUntilClear = 1 // It will survive exactly 1 more move
        
        // Turn it into a dead block (wipes visuals, makes it gray)
        healer.removeAllChildren()
        let deadVisual = SKSpriteNode(color: .darkGray, size: healer.size)
        deadVisual.alpha = 0.8
        healer.addChild(deadVisual)

        // Snap it back to the hand slot to clog it
        if let snapBackPos = healer.userData?["startingPosition"] as? CGPoint {
            healer.run(SKAction.move(to: snapBackPos, duration: 0.2))
        }

        registerMove()
        return true
    }

    func resolveArmorCombat(enemy: Card, armor: Card) -> Bool {
        let enemyDamage = enemy.rank.value
        let armorValue = armor.rank.value

        let remainingArmor = armorValue - enemyDamage
        let remainingDamage = enemyDamage - armorValue

        // 1. Destroy the Enemy (It always dies when hitting armor)
        removeFromOldSlot(enemy)
        enemy.run(SKAction.sequence([SKAction.scale(to: 0.1, duration: 0.2), SKAction.removeFromParent()]))

        // 2. Calculate Armor Survival
        if remainingArmor <= 0 {
            print("🛡️ Armor shattered!")
            removeFromOldSlot(armor)
            armor.run(SKAction.sequence([SKAction.scale(to: 0.1, duration: 0.2), SKAction.removeFromParent()]))
        } else {
            print("🛡️ Armor survives with \(remainingArmor) left!")
            armor.updateRank(to: Rank.from(value: remainingArmor))
        }

        // 3. Overflow Damage hits Hermit
        if remainingDamage > 0 {
            print("💥 Overflow! Hermit takes \(remainingDamage) damage!")
            self.hermit.takeDamage(amount: remainingDamage)
        }

        registerMove()
        return true
    }

    func resolveDirectDamage(enemy: Card) -> Bool {
        print("💥 Hermit takes \(enemy.rank.value) direct damage!")
        
        enemy.triggerEffect(hermit: self.hermit)
        
        removeFromOldSlot(enemy)
        enemy.run(SKAction.sequence([SKAction.scale(to: 0.1, duration: 0.2), SKAction.removeFromParent()]))

        registerMove()
        return true
    }

    // MARK: - Helper Functions

    // Safely removes a card from its old column's memory
    func removeFromOldSlot(_ card: Card) {
        let oldSlot = card.currentSlotName
            
        if oldSlot != "" {
            let oldCount = columnCounts[oldSlot, default: 0]
            if oldCount > 0 {
                columnCounts[oldSlot] = oldCount - 1
            }
            card.currentSlotName = ""
            
            // --- THE FIX: If pulled from the middle, collapse the gap! ---
            if oldSlot.hasPrefix("Middle_Col_") {
                collapseMiddleColumn(slotName: oldSlot)
            }
            
            revealBottomCards()
        }
    }

    // Checks if a card is the absolute last one in its stack
    func isLastCard(_ card: Card) -> Bool {
        let count = columnCounts[card.currentSlotName, default: 0]
        return card.name == "\(card.currentSlotName)_Card_\(count - 1)"
    }

    // Grabs the bottom-most card of any column (so we can check its Suit!)
    func getBottomCard(in slotName: String) -> Card? {
        let count = columnCounts[slotName, default: 0]
        if count == 0 { return nil }
        return self.childNode(withName: "\(slotName)_Card_\(count - 1)") as? Card
    }
    
    // Checks the hand slots and deletes dead cards if their time is up
    func tickCooldowns() {
        for slot in ["Bottom_Col_0", "Bottom_Col_2"] {
            if let card = getBottomCard(in: slot), card.isExhausted {
                card.movesUntilClear -= 1
                
                if card.movesUntilClear < 0 { // Time is up!
                    print("💨 Cooldown finished. Clearing slot.")
                    removeFromOldSlot(card)
                    card.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()]))
                }
            }
        }
    }
    
    private func collapseMiddleColumn(slotName: String) {
        guard let slotNode = self.childNode(withName: slotName) as? SKSpriteNode else { return }
        
        // 1. Find all cards still left in this column
        var remainingCards: [Card] = []
        for node in self.children {
            if let c = node as? Card, c.currentSlotName == slotName {
                remainingCards.append(c)
            }
        }
        
        // 2. Sort them physically from Top to Bottom
        remainingCards.sort { $0.position.y > $1.position.y }
        
        let cellHeight = slotNode.size.height / 4.0
        let slotCenterX = slotNode.position.x + (slotNode.size.width / 2.0)
        let slotTopY = slotNode.position.y + slotNode.size.height
        
        // 3. Rename them 0, 1, 2... and snap them to their perfect grid slots
        for (index, c) in remainingCards.enumerated() {
            c.name = "\(slotName)_Card_\(index)"
            
            let newY = slotTopY - (cellHeight / 2.0) - (CGFloat(index) * cellHeight)
            let snap = SKAction.move(to: CGPoint(x: slotCenterX, y: newY), duration: 0.2)
            c.run(snap)
            c.zPosition = 20 - CGFloat(index)
        }
    }
    
    // Flips the lowest card in every column face-up
    func revealBottomCards() {
        for i in 0..<4 {
            let slotName = "Middle_Col_\(i)"
            if let bottomCard = getBottomCard(in: slotName) {
                bottomCard.isFaceUp = true
            }
        }
    }
}
