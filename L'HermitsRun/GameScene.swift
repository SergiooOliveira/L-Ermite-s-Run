//
//  GameScene.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/04/2026.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var hermit: Hermit = Hermit(health: 20, armor: 0, damage: 0)
    
    var columnCounts: [String:Int] = [:]
    
    override func didMove(to view: SKView) {
        // Call this when the scene loads
        createBoardLayout()
    }
    
    func createBoardLayout() {
        self.anchorPoint = .zero
        let screenWidth = self.size.width
        let screenHeight = self.size.height
        
        let gap: CGFloat = 4.0
        
        // 1. Define Proportions (Adjust these percentages as needed)
        let topHeight = screenHeight * 0.25    // Top section = 20%
        let bottomHeight = screenHeight * 0.25 // Bottom section = 20%
        let middleHeight = screenHeight - topHeight - bottomHeight - (gap * 2) // Remaining 60%
        let columnWidth = (screenWidth - (gap * 3)) / 4      // 4 equal columns
        
        // 2. Build the Top Header
        // Using a slightly smaller width/height multiplier (0.98) to act as visual padding
        let topNode = SKSpriteNode(color: .darkGray, size: CGSize(width: screenWidth, height: topHeight))
        topNode.name = "TopHeader"
        topNode.anchorPoint = .zero
        // Calculate Y position to snap it to the top edge
        topNode.position = CGPoint(x: 0, y: screenHeight - topHeight)
        addChild(topNode)
        
        // 3. Build Middle Row (4 Columns)
        let middleY = bottomHeight + gap
        generateRow(yPosition: middleY, height: middleHeight, colWidth: columnWidth, gap: gap, color: .gray, rowName: "Middle")
        
        // 4. Build Bottom Row (4 Columns)
        let bottomY: CGFloat = 0.0
        generateRow(yPosition: bottomY, height: bottomHeight, colWidth: columnWidth, gap: gap, color: .lightGray, rowName: "Bottom")
    }
    
    // Helper function to build the 4-column layout modularly
    func generateRow(yPosition: CGFloat, height: CGFloat, colWidth: CGFloat, gap: CGFloat, color: UIColor, rowName: String) {
        for i in 0..<4 {
            // Create a node for each column cell
            let cell = SKSpriteNode(color: color, size: CGSize(width: colWidth, height: height))
            
            // Name it so you can easily reference it later (e.g., "Middle_Col_0")
            cell.name = "\(rowName)_Col_\(i)"
            cell.anchorPoint = .zero
            
            // Shift the X position right for each subsequent column
            let xPos = (CGFloat(i) * colWidth) + (CGFloat(i) * gap)
            cell.position = CGPoint(x: xPos, y: yPosition)
            addChild(cell)
        }
    }
    
    func createCard(in targetColumn: SKSpriteNode, cardIndex: Int) {
        let colWidth = targetColumn.frame.width
        let colHeight = targetColumn.frame.height
        
        let cardWidth = colWidth * 0.85
        let cardHeight = cardWidth * 1.4
        let finalCardHeight = min(cardHeight, colHeight * 0.9)
        let finalCardSize = CGSize(width: cardWidth, height: finalCardHeight)
        
        let testCard = SKSpriteNode(color: .blue, size: finalCardSize)
        testCard.name = "Card_\(cardIndex)"
        
        // Calculate the exact offset so 4 cards (3 gaps) fit perfectly in the column
        let remainingVerticalSpace = colHeight - finalCardHeight
        let yOffset = remainingVerticalSpace / 3.0
        
        // Calculate the exact center X of the column
        let centerX = targetColumn.frame.midX
        
        // Calculate the top position.
        // Since cards have a center anchorPoint (0.5, 0.5), we push it down by half its height so it doesn't bleed out the top.
        let startY = targetColumn.frame.maxY - (finalCardHeight / 2.0)
        
        // Move the card down based on its index
        testCard.position = CGPoint(
            x: centerX,
            y: startY - (CGFloat(cardIndex) * yOffset)
        )
        
        // Force the newer cards to render ON TOP of the older cards
        testCard.zPosition = 10 + CGFloat(cardIndex)
        
        self.addChild(testCard)
    }
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let touchedNode = self.atPoint(location)
        
        if let nodeName = touchedNode.name, nodeName.contains("Middle_Col_") {
            print("Pressed on \(nodeName)")
            
            // 1. Cast the node so we can read its dimensions
            if let targetColumn = touchedNode as? SKSpriteNode {
                
                // 2. Check our dictionary to see how many cards are already here (defaults to 0)
                let currentCardCount = columnCounts[nodeName, default: 0]
                print("currentCardCount: \(currentCardCount)")
                
                // 3. Prevent spawning if the column is already full
                if currentCardCount < 4 {
                    print("Creating card")
                    // Spawn the card at the correct index
                    createCard(in: targetColumn, cardIndex: currentCardCount)
                    
                    // Update our tracker so the next tap pushes the next card further down
                    columnCounts[nodeName] = currentCardCount + 1
                    
                } else {
                    print("\(nodeName) is full! Cannot add more cards.")
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
