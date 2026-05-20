//
//  Hermit.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/04/2026.
//

import Foundation
import SpriteKit

class Hermit: SKSpriteNode {
    
    var health: Int
    var maxHealth: Int
    var gold: Int
    
    init(health: Int, size: CGSize) {
        self.health = health
        self.maxHealth = health
        self.gold = 0
        
        super.init(texture: nil, color: .purple, size: size)
        setupVisuals()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func triggerCard(card: Card) {
        card.triggerEffect(hermit: self)
        updateVisuals()
    }
    
    // Mark - Visuals
    private func setupVisuals() {
        // Add a simple text label so we know this is the Hermit
        let label = SKLabelNode(text: "HP: \(health)")
        
        label.name = "HermitHPLabel"
        label.fontSize = 16
        label.fontName = "Helvetica-Bold"
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        
        addChild(label)
    }
    
    func updateVisuals() {
        if let label = self.childNode(withName: "HermitHPLabel") as? SKLabelNode {
            label.text = "HP: \(health)"
        }
    }
    
    // MARK: Helper Methods
    func takeDamage(amount: Int) {
        self.health = max(0, self.health - amount)
        self.updateVisuals()
    }
    
    func heal(amount: Int) {
        self.health = min(self.maxHealth, self.health + amount)
        self.updateVisuals()
    }
    
    func addGold(amount: Int) {
        self.gold += amount
        self.updateVisuals()
    }
}
