//
//  Card.swift
//  L'HermitsRun
//
//  Created by Sérgio Oliveira on 22/04/2026.
//

import Foundation
import SpriteKit

class Card: SKSpriteNode {
    
    var rank : Rank
    var suit : Suit
    var isFaceUp: Bool = false

    // MARK: - Dragging Properties
    private var touchOffset: CGPoint = .zero
    private var originalZPosition: CGFloat = 0
    private var startingPosition: CGPoint = .zero
    
    init(rank : Rank, suit : Suit, size: CGSize) {
        self.rank = rank
        self.suit = suit
        
        let cardColor: UIColor
        switch suit {
        case .spades:   cardColor = .black
        case .hearts:   cardColor = .red
        case .clubs:    cardColor = .green
        case .diamonds: cardColor = UIColor(red: 0.68, green: 0.85, blue: 0.90, alpha: 1.0) // Light blue
        }
        
        // Initialize the SKSpriteNode under the hood
        super.init(texture: nil, color: cardColor, size: size)
        
        // CRITICAL: Let SpriteKit know this node can be tapped/dragged
        self.isUserInteractionEnabled = true
        
        setupVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Visual Setup
    private func setupVisuals() {
        let rankString = getRankString()
        
        let label = SKLabelNode(text: "\(rankString) \(suit)")
        label.fontSize = 16
        label.fontName = "Helvetica-Bold"
        // Black text on diamonds/clubs so it's readable
        label.fontColor = (suit == .diamonds || suit == .clubs) ? .black : .white
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        
        addChild(label)
    }
    
    private func getRankString() -> String {
        switch rank {
        case .ace: return "A"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        default: return "\(rank.value)"
        }
    }
    
    // MARK: - Dragging Logic
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let parent = self.parent else { return }
        
        let touchLocation = touch.location(in: parent)
        touchOffset = CGPoint(x: position.x - touchLocation.x, y: position.y - touchLocation.y)
        
        // Save the original layering so we can restore it later
        originalZPosition = self.zPosition
        
        // Pop to the front and make slightly transparent while dragging
        self.zPosition = 999
        self.alpha = 0.8
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let parent = self.parent else { return }
        let touchLocation = touch.location(in: parent)
        
        self.position = CGPoint(x: touchLocation.x + touchOffset.x, y: touchLocation.y + touchOffset.y)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1. Reset visuals when dropped
        self.zPosition = originalZPosition
        self.alpha = 1.0
        
        // Safety check to make sure the card is actually on the screen
        guard let scene = self.scene, let parent = self.parent else { return }
        
        // 2. Find exactly where the center of the card is in the main Scene
        let locationInScene = parent.convert(self.position, to: scene)
        
        // 3. CREATE OUR VARIABLES: Ask the Scene for every node under this exact spot
        let nodesUnderCard = scene.nodes(at: locationInScene)
        var hitHermit = false
        var hitColumn = false
        
        // 4. Look through the pile of nodes to see what we dropped the card on
        for node in nodesUnderCard {
            
            // --- CHECK A: Did we drop it on the Hermit? ---
            if let hermitNode = node as? Hermit {
                hitHermit = true
                print("💥 Card dropped on the Hermit!")
                
                // Trigger your custom logic and update the UI
                triggerEffect(hermit: hermitNode)
                hermitNode.updateVisuals()
                
                // Animate the card vanishing (scale down and fade out)
                let scaleDown = SKAction.scale(to: 0.1, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let remove = SKAction.removeFromParent()
                self.run(SKAction.sequence([SKAction.group([scaleDown, fadeOut]), remove]))
                
                break // Stop looking, we found the Hermit!
            }
            
            // --- CHECK B: Did we drop it on a Column? ---
            if let colName = node.name, colName.contains("Middle_Col_") {
                if let targetCol = node as? SKSpriteNode, let board = self.parent as? Board {
                    hitColumn = true
                    
                    // Pass the card to the Board to slot it in
                    board.receiveDroppedCard(self, in: targetCol)
                    
                    break // Stop looking, we found a column!
                }
            }
        }
        
        // 5. The "Snap Back" Failsafe
        // If it didn't hit the Hermit AND it didn't hit a Column, fly back home.
        if !hitHermit && !hitColumn {
            let snapBack = SKAction.move(to: startingPosition, duration: 0.2)
            snapBack.timingMode = .easeOut // Makes the animation look smoother
            self.run(snapBack)
        }
    }
    
    func triggerEffect(hermit: Hermit) {
        switch self.suit {
        case .clubs:
            // Trigger clubs
            clubEffect(value: self.rank.value, hermit: hermit)
        case .diamonds:
            // Trigger diamond
            diamondsEffect(value: self.rank.value, hermit: hermit)
        case .hearts:
            // Trigger hearts
            heartsEffect(value: self.rank.value, hermit: hermit)
        case .spades:
            // Trigger spades
            spadesEffect(value: self.rank.value, hermit: hermit)
        }
    }
    
    private func clubEffect(value: Int, hermit: Hermit) {
        // Armor
        hermit.armor += value
        print("Added \(value) to armor, new value: \(hermit.armor)");
    }
    
    private func diamondsEffect(value: Int, hermit: Hermit) {
        // Take damage
        
        hermit.health = max(0, hermit.health - value)
        
        print("Hermit took \(value) to hp, new value: \(hermit.health)");
    }
    
    private func heartsEffect(value: Int, hermit: Hermit) {
        // Heal
        hermit.health = min(hermit.maxHealth, hermit.health + value)
        print("Healed \(value), new value: \(hermit.health)");
    }
    
    private func spadesEffect(value: Int, hermit: Hermit) {
        // Damage
        hermit.damage += value
        print("Added \(value) to damage, new value: \(hermit.damage)");
    }
}
