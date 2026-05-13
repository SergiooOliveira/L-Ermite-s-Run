import SpriteKit

class Board: SKNode {
    
    // Tracks how many cards are currently in each column
    var columnCounts: [String: Int] = [:]
    
    // We need to store the size so the board knows how big to draw itself
    private let boardSize: CGSize
    
    var hermit: Hermit
    var gameDeck: Deck!
    
    // Initialization
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
        
        // 2. Build the Deck with the perfect size!
        self.gameDeck = Deck(hermit: self.hermit, cardSize: calculatedCardSize)
        
        createBoardLayout()
        createButtonInTopCell()
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
        addChild(topNode) // Adds to the Board node, not the Scene
        
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
    
    // MARK: - Game Mechanics
    
    func spawnCard(in targetColumn: SKSpriteNode, cardIndex: Int) {
        guard !gameDeck.deck.isEmpty else {
            print("The deck is empty!")
            return
        }
        
        let newCard = gameDeck.deck.removeFirst()
        let finalCardHeight = newCard.size.height
        
        newCard.name = "\(targetColumn.name ?? "Col")_Card_\(cardIndex)"
        
        // --- FIX 1: THE Y-OFFSET MATH ---
        // Instead of dividing empty space, we make every drop a satisfying 25% of the card's height!
        let colHeight = targetColumn.frame.height
        let yOffset = (colHeight - finalCardHeight) / 3.0
        
        let centerX = targetColumn.frame.midX
        let startY = targetColumn.frame.maxY - (finalCardHeight / 2.0)
        
        newCard.position = CGPoint(x: centerX, y: startY - (CGFloat(cardIndex) * yOffset))
        
        // --- FIX 2: THE Z-POSITION ---
        // The newest card (index 0) gets the highest number (20).
        // As they get pushed down (index 1, 2, 3), their layer number gets lower so they tuck underneath!
        newCard.zPosition = 20 - CGFloat(cardIndex)
        
        self.addChild(newCard)
    }
    
    func dealOneCardToAllColumns() {
        for i in 0..<4 {
            let nodeName = "Middle_Col_\(i)"
            if let targetColumn = self.childNode(withName: nodeName) as? SKSpriteNode {
                insertCardAtTop(in: targetColumn)
            }
        }
    }
    
    // MARK: - The Push-Down Mechanic
        
    func insertCardAtTop(in targetColumn: SKSpriteNode) {
        let colName = targetColumn.name ?? "Col"
        let currentCardCount = columnCounts[colName, default: 0]
        
        if currentCardCount == 4 {
            if let bottomCard = self.childNode(withName: "\(colName)_Card_3") {
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let remove = SKAction.removeFromParent()
                bottomCard.run(SKAction.sequence([fadeOut, remove]))
            }
        }
        
        // Match the massive 25% drop offset
        let colHeight = targetColumn.frame.height
                let cardWidth = targetColumn.frame.width * 0.85
                let finalCardHeight = min(cardWidth * 1.4, colHeight * 0.9)
                let yOffset = (colHeight - finalCardHeight) / 3.0
        
        let topIndexToMove = min(currentCardCount - 1, 2)
        
        if topIndexToMove >= 0 {
            for i in (0...topIndexToMove).reversed() {
                if let card = self.childNode(withName: "\(colName)_Card_\(i)") {
                    card.name = "\(colName)_Card_\(i + 1)"
                    
                    let moveDown = SKAction.moveBy(x: 0, y: -yOffset, duration: 0.2)
                    card.run(moveDown)
                    
                    // The old cards tuck *underneath* the new top card
                    card.zPosition = 20 - CGFloat(i + 1)
                }
            }
        }
        
        let delay: TimeInterval = currentCardCount > 0 ? 0.2 : 0.0
        let wait = SKAction.wait(forDuration: delay)
        let spawnNew = SKAction.run {
            self.spawnCard(in: targetColumn, cardIndex: 0)
        }
        self.run(SKAction.sequence([wait, spawnNew]))
        
        if currentCardCount < 4 {
            columnCounts[colName] = currentCardCount + 1
        }
    }
    
    func receiveDroppedCard(_ droppedCard: Card, in targetColumn: SKSpriteNode) {
        let colName = targetColumn.name ?? "Col"
        let currentCardCount = columnCounts[colName, default: 0]
        
        if currentCardCount == 4 {
            if let bottomCard = self.childNode(withName: "\(colName)_Card_3") {
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let remove = SKAction.removeFromParent()
                bottomCard.run(SKAction.sequence([fadeOut, remove]))
            }
        }
        
        // Match the massive 25% drop offset
        let colHeight = targetColumn.frame.height
                let finalCardHeight = droppedCard.size.height
                let yOffset = (colHeight - finalCardHeight) / 3.0
        
        let topIndexToMove = min(currentCardCount - 1, 2)
        if topIndexToMove >= 0 {
            for i in (0...topIndexToMove).reversed() {
                if let card = self.childNode(withName: "\(colName)_Card_\(i)") {
                    card.name = "\(colName)_Card_\(i + 1)"
                    
                    let moveDown = SKAction.moveBy(x: 0, y: -yOffset, duration: 0.2)
                    card.run(moveDown)
                    
                    // The old cards tuck *underneath* the new top card
                    card.zPosition = 20 - CGFloat(i + 1)
                }
            }
        }
        
        droppedCard.name = "\(colName)_Card_0"
        let centerX = targetColumn.frame.midX
        let startY = targetColumn.frame.maxY - (finalCardHeight / 2.0)
        
        let snapToSpot = SKAction.move(to: CGPoint(x: centerX, y: startY), duration: 0.2)
        droppedCard.run(snapToSpot)
        
        // The newly dropped card gets the highest layer
        droppedCard.zPosition = 20
        
        if currentCardCount < 4 {
            columnCounts[colName] = currentCardCount + 1
        }
    }
    
}
