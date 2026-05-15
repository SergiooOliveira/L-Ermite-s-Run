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
    var currentSlotName: String = ""

    // MARK: - Dragging Properties
    private var touchOffset: CGPoint = .zero
    private var originalZPosition: CGFloat = 0
    private var startingPosition: CGPoint = .zero
    private var isDragging: Bool = false
    
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
        guard let board = self.parent as? Board else { return }
        
        // --- RULE: Only the last card in a stack can be dragged! ---
        guard board.isLastCard(self) else {
            print("🔒 Not the last card! Dragging disabled.")
            return
        }
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: board)
        touchOffset = CGPoint(x: position.x - touchLocation.x, y: position.y - touchLocation.y)
        
        originalZPosition = self.zPosition
        startingPosition = self.position
        
        self.zPosition = 999
        self.alpha = 0.8
        
        self.isDragging = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        self.isDragging = false
        
        self.zPosition = originalZPosition
        self.alpha = 1.0
        
        guard let scene = self.scene, let parent = self.parent else { return }
        let locationInScene = parent.convert(self.position, to: scene)
        let nodesUnderCard = scene.nodes(at: locationInScene)
        
        var successfulDrop = false
        
        for node in nodesUnderCard {
                    
            // 1. Did we drop on the Hermit?
            if let hermitNode = node as? Hermit {
                successfulDrop = true
                triggerEffect(hermit: hermitNode)
                hermitNode.updateVisuals()
                
                if let board = self.parent as? Board {
                    board.removeFromOldSlot(self)
                    board.registerMove() // <--- Manually feeding the Hermit counts as a move!
                }
                
                let vanish = SKAction.sequence([SKAction.scale(to: 0.1, duration: 0.2), SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()])
                self.run(vanish)
                break
            }
            
            var targetSlotName: String? = nil
            
            // 2. Did we hit ANY valid empty slot background?
            if let colName = node.name, (colName.hasPrefix("Middle_Col_") || colName.hasPrefix("Bottom_Col_")) && !colName.contains("_Card_") && colName != "Bottom_Col_1" {
                targetSlotName = colName
            }
            // 3. Did we hit another Card?
            else if let targetCard = node as? Card, targetCard != self {
                targetSlotName = targetCard.currentSlotName
            }
            
            // 4. Validate and Execute the Drop!
            if let slotName = targetSlotName, let board = self.parent as? Board {
                
                if let bottomCard = board.getBottomCard(in: slotName), bottomCard.suit == .clubs {
                    print("❌ Rule violation: Cannot drop on a Club!")
                } else {
                    // Ask the Board to append it. If the column is full, it returns false and fails the drop!
                    successfulDrop = board.appendCard(self, toSlot: slotName)
                    
                    if successfulDrop {
                        break // Everything worked, stop looking!
                    }
                }
            }
        }
        
        // 5. The Failsafe
        if !successfulDrop {
            let snapBack = SKAction.move(to: startingPosition, duration: 0.2)
            snapBack.timingMode = .easeOut
            self.run(snapBack)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        
        guard let touch = touches.first, let parent = self.parent else { return }
        let touchLocation = touch.location(in: parent)
        
        self.position = CGPoint(x: touchLocation.x + touchOffset.x, y: touchLocation.y + touchOffset.y)
    }
    
    // MARK: Effects
    
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
        // Take damage
        
        hermit.health = max(0, hermit.health - value)
        print("Hermit took \(value) to hp, new value: \(hermit.health)");
    }
    
    private func diamondsEffect(value: Int, hermit: Hermit) {
        // Armor
        hermit.armor += value
        print("Added \(value) to armor, new value: \(hermit.armor)");
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
