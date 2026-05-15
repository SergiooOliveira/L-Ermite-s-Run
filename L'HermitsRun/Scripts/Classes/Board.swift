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
        let finalCardHeight = min(cardWidth * 1.4, middleHeight * 0.9)
        let calculatedCardSize = CGSize(width: cardWidth, height: finalCardHeight)
        
        // Build the Deck with the perfect size!
        self.gameDeck = Deck(hermit: self.hermit, cardSize: calculatedCardSize)
        
        createBoardLayout()
        createButtonInTopCell()
        placeHermitInBottomRow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Generation
    
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
    
    private func createButtonInTopCell() {
        if let topHeader = self.childNode(withName: "TopHeader") as? SKSpriteNode {
            let button = SKSpriteNode(color: .black, size: CGSize(width: 140, height: 44))
            button.name = "TopCellButton"
            button.zPosition = 10
            
            let headerCenterX = topHeader.frame.width / 2
            let headerCenterY = topHeader.frame.height / 2
            button.position = CGPoint(x: headerCenterX, y: headerCenterY)
            
            let label = SKLabelNode(text: "Top Button")
            label.fontSize = 18
            label.fontName = "Helvetica-Bold"
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.name = "TopCellButtonLabel"
            
            button.addChild(label)
            topHeader.addChild(button)
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
        
        // If we made it here, the move was completely successful
        registerMove()
        return true
    }
    
    func registerMove() {
        moveCounter += 1
        print("Moves: \(moveCounter)/3")
        
        if moveCounter >= 3 {
            moveCounter = 0
            print("🃏 Auto-Dealing new row!")
            
            // Wait 0.3 seconds so the user's drop animation finishes before the new cards fly in
            let wait = SKAction.wait(forDuration: 0.3)
            let deal = SKAction.run { [weak self] in
                self?.dealOneCardToAllColumns()
            }
            self.run(SKAction.sequence([wait, deal]))
        }
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
        
        // Standard stacking math (adds to the bottom without shifting others)
        let colHeight = slotNode.frame.height
        let yOffset = (colHeight - card.size.height) / 3.0
        let startY = slotNode.frame.maxY - (card.size.height / 2.0)
        let newY = startY - (CGFloat(count) * yOffset)
        
        let snap = SKAction.move(to: CGPoint(x: slotNode.frame.midX, y: newY), duration: 0.2)
        card.run(snap)
        card.zPosition = 30 + CGFloat(count) // Render clearly on top
        
        columnCounts[slotName] = count + 1
    }

    private func appendToBottomRow(_ card: Card, slotName: String) {
        guard let slotNode = self.childNode(withName: slotName) as? SKSpriteNode else { return }
        let count = columnCounts[slotName, default: 0]
        
        card.name = "\(slotName)_Card_\(count)"
        card.currentSlotName = slotName
        
        let yOffset = card.size.height / 3.0
        let slotCenterY = slotNode.position.y + (slotNode.size.height / 2.0)
        let slotCenterX = slotNode.position.x + (slotNode.size.width / 2.0)
        
        let newY = slotCenterY - (CGFloat(count) * yOffset)
        
        /*
        let startY = slotNode.frame.maxY - (card.size.height / 2.0)
        let newY = startY - (CGFloat(count) * yOffset)
        */
        let snap = SKAction.move(to: CGPoint(x: slotNode.frame.midX, y: newY), duration: 0.2)
        card.run(snap)
        card.zPosition = 30 + CGFloat(count) // Render on top of the card below it
        
        columnCounts[slotName] = count + 1
    }
    
    private func dealConveyorToMiddleColumn(_ card: Card, slotName: String) {
        guard let slotNode = self.childNode(withName: slotName) as? SKSpriteNode else { return }
        var count = columnCounts[slotName, default: 0]
        
        // Trigger effect when pushing off the bottom card!
        if count >= 4 {
            if let bottomCard = self.childNode(withName: "\(slotName)_Card_3") as? Card {
                print("💥 Conveyor pushed off a card! Triggering effect.")
                
                // Damage/Heal the Hermit before it gets deleted!
                self.hermit.triggerCard(card: bottomCard)
                
                let vanish = SKAction.sequence([SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()])
                bottomCard.run(vanish)
            }
            count = 3 // We successfully made room!
        }
        
        // Shift existing cards DOWN
        let colHeight = slotNode.frame.height
        let yOffset = (colHeight - card.size.height) / 3.0
        
        if count > 0 {
            for i in (0..<count).reversed() {
                if let oldCard = self.childNode(withName: "\(slotName)_Card_\(i)") as? Card {
                    oldCard.name = "\(slotName)_Card_\(i + 1)"
                    let moveDown = SKAction.moveBy(x: 0, y: -yOffset, duration: 0.2)
                    oldCard.run(moveDown)
                    oldCard.zPosition = 20 - CGFloat(i + 1)
                }
            }
        }
        
        // Slot new card at the Top
        card.name = "\(slotName)_Card_0"
        card.currentSlotName = slotName
        
        let startY = slotNode.frame.maxY - (card.size.height / 2.0)
        let snap = SKAction.move(to: CGPoint(x: slotNode.frame.midX, y: startY), duration: 0.2)
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

    // MARK: - Helper Functions

    // Safely removes a card from its old column's memory
    func removeFromOldSlot(_ card: Card) {
        if card.currentSlotName != "" {
            let oldCount = columnCounts[card.currentSlotName, default: 0]
            if oldCount > 0 {
                columnCounts[card.currentSlotName] = oldCount - 1
            }
            card.currentSlotName = ""
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
}
