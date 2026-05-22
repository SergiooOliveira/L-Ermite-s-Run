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
    var currentSlotName: String = ""
    var displayLabel: SKLabelNode!
    var isFaceUp: Bool = false {
        didSet { updateVisuals() }
    }

    // MARK: - Dragging Properties
    private var touchOffset: CGPoint = .zero
    private var originalZPosition: CGFloat = 0
    private var startingPosition: CGPoint = .zero
    private var isDragging: Bool = false
    var isExhausted: Bool = false
    var movesUntilClear: Int = 0
    
    init(rank : Rank, suit : Suit, size: CGSize) {
        self.rank = rank
        self.suit = suit
        
        // Initialize the SKSpriteNode under the hood
        super.init(texture: nil, color: .white, size: size)
        
        // CRITICAL: Let SpriteKit know this node can be tapped/dragged
        self.isUserInteractionEnabled = true
        
        // 2. Add a clean black border
        let border = SKShapeNode(rectOf: size, cornerRadius: 6.0)
        border.strokeColor = .black
        border.lineWidth = 2.0
        self.addChild(border)
        
        // 3. Create the Emoji Text
        let rankString = getRankString()
        displayLabel = SKLabelNode(text: "\(suit.emoji) \(rankString)")
        displayLabel.fontName = "Helvetica-Bold"
        displayLabel.fontSize = size.width * 0.30
        displayLabel.fontColor = suit.displayColor
        displayLabel.verticalAlignmentMode = .center
        displayLabel.zPosition = 1
        
        self.addChild(displayLabel)
        updateVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Visuals
    private func updateVisuals() {
        self.color = isFaceUp ? .white : .black
        self.displayLabel.isHidden = !isFaceUp
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
    
    func updateRank(to newRank: Rank) {
        self.rank = newRank
        self.displayLabel.text = "\(self.suit.emoji) \(getRankString())"
        
        // A satisfying little pop animation when a stat changes
        let pop = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        self.displayLabel.run(pop)
    }
    
    // MARK: - Dragging Logic
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isExhausted else {
            print("Card is on Cooldown")
            return
        }
        
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
            // --- 0. Did we drop on the Top Row to Sell? ---
            if node.name == "TopHeader" || node.name == "TopCellButton" || node.name == "TopCellButtonLabel" {
                
                if self.suit == .clubs {
                    print("Cant sell enemies")
                    break
                }
                
                if let board = self.parent as? Board {
                    successfulDrop = board.sellCard(self)
                    if successfulDrop { break }
                }
            }
            
            // --- 1. Did we drop on the Hermit? ---
            if let _ = node as? Hermit, let board = self.parent as? Board {
                let isFromHand = (self.currentSlotName == "Bottom_Col_0" || self.currentSlotName == "Bottom_Col_2")
                
                // A: Direct Enemy Attack (Clubs onto Hermit)
                if self.suit == .clubs {
                    successfulDrop = board.resolveDirectDamage(enemy: self)
                }
                // B: Healing (Hearts from Hand onto Hermit)
                else if self.suit == .hearts && isFromHand {
                    self.userData = ["startingPosition": startingPosition] // Remember hand slot so it snaps back
                    successfulDrop = board.resolveHeal(healer: self)
                }
                // C: Fallback / Trashing other cards on the Hermit
                else {
                    print("Invalid interaction")
                    break
                }
                
                if successfulDrop { break } // Stop looking, Hermit handled it!
            }
            
            var targetSlotName: String? = nil
            
            // --- 2. Did we hit ANY valid empty slot background? ---
            if let colName = node.name, (colName.hasPrefix("Middle_Col_") || colName.hasPrefix("Bottom_Col_")) && !colName.contains("_Card_") && colName != "Bottom_Col_1" {
                targetSlotName = colName
            }
            
            // --- 3. Did we hit another Card? ---
            else if let targetCard = node as? Card, targetCard != self {
                targetSlotName = targetCard.currentSlotName
                
                let isFromHand = (self.currentSlotName == "Bottom_Col_0" || self.currentSlotName == "Bottom_Col_2")
                let targetIsHand = (targetSlotName == "Bottom_Col_0" || targetSlotName == "Bottom_Col_2")
                
                if let board = self.parent as? Board {
                    
                    // Combat A: Spades (Weapon in Hand) vs Clubs (Enemy anywhere)
                    if isFromHand && self.suit == .spades && targetCard.suit == .clubs {
                        self.userData = ["startingPosition": startingPosition]
                        successfulDrop = board.resolveCombat(attacker: self, defender: targetCard)
                        if successfulDrop { break }
                    }
                    
                    // Combat B: Clubs (Enemy dragged) vs Diamonds (Armor in Hand)
                    else if targetIsHand && self.suit == .clubs && targetCard.suit == .diamonds {
                        successfulDrop = board.resolveArmorCombat(enemy: self, armor: targetCard)
                        if successfulDrop { break }
                    }
                }
            }
            
            // --- 4. Validate and Execute standard Drops! ---
            if let slotName = targetSlotName, let board = self.parent as? Board {
                
                let isOriginBottom = self.currentSlotName.hasPrefix("Bottom_Col_")
                let isOriginHand = (self.currentSlotName == "Bottom_Col_0" || self.currentSlotName == "Bottom_Col_2")
                
                let isTargetMiddle = slotName.hasPrefix("Middle_Col_")
                let isTargetHand = (slotName == "Bottom_Col_0" || slotName == "Bottom_Col_2")
                let isTargetBackpack = (slotName == "Bottom_Col_3")
                
                // --- STRICT MOVEMENT RULES ---
                
                // Rule 1: No going back to the board
                if isOriginBottom && isTargetMiddle {
                    print("❌ Invalid: Cannot move cards from Hand/Backpack back to the Board!")
                    break // Snaps back
                }
                
                // Rule 2: No moving from Hand to Backpack
                if isOriginHand && isTargetBackpack {
                    print("❌ Invalid: Cards in the Hand cannot be moved to the Backpack!")
                    break
                }
                
                // Rule 3: No Clubs in the Hand
                if self.suit == .clubs && isTargetHand {
                    print("❌ Invalid: Clubs (Enemies) can never be placed in the Hand slots!")
                    break
                }
                
                // Rule 4: Cannot stack on top of a Club
                if let bottomCard = board.getBottomCard(in: slotName), bottomCard.suit == .clubs {
                    print("❌ Invalid: Cannot stack on top of a Club!")
                    break
                }
                
                // --- EXECUTE DROP ---
                // If it survived all the rules above, the move is totally legal!
                successfulDrop = board.appendCard(self, toSlot: slotName)
                if successfulDrop { break }
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
        case .hearts:
            // Trigger hearts
            heartsEffect(value: self.rank.value, hermit: hermit)
        case .spades, .diamonds:
            // Trigger spades
            break
        }
    }
    
    private func clubEffect(value: Int, hermit: Hermit) {
        // Take damage
        
        hermit.takeDamage(amount: value)
    }
    
    private func heartsEffect(value: Int, hermit: Hermit) {
        // Heal
        hermit.heal(amount: value)
    }
    
}
