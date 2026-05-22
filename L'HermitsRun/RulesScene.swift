//
//  RulesScene.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/05/2026.
//

import Foundation
import SpriteKit

class RulesScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .darkGray
        
        // 1. The Title
        let titleLabel = SKLabelNode(text: "HOW TO PLAY")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .systemYellow
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        addChild(titleLabel)
        
        // 2. The Core Rules Text
        let rulesText = """
        SURVIVAL MECHANICS:
        • ♣️ CLUBS (Enemies): Drop on Hermit to take damage.
        • ♥️ HEARTS (Potions): Drop on Hermit to heal.
        • ♠️ SPADES (Weapons): Drop on Clubs to attack.
        • ♦️ DIAMONDS (Armor): Drop Clubs on these to block.

        MOVEMENT & ECONOMY:
        • Drag only the bottom, face-up cards.
        • Drag cards to the Top Bar to sell for Gold.
        • You cannot sell Clubs!
        • Bottom row holds 2 active cards and 1 backpack slot.
        """
        
        let textLabel = SKLabelNode(text: rulesText)
        textLabel.fontName = "Helvetica"
        textLabel.fontSize = 18
        textLabel.fontColor = .white
        textLabel.numberOfLines = 0
        textLabel.horizontalAlignmentMode = .center
        textLabel.verticalAlignmentMode = .top
        textLabel.preferredMaxLayoutWidth = size.width * 0.85
        textLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        addChild(textLabel)
        
        // 3. The Back Button
        let backButton = SKSpriteNode(color: .systemRed, size: CGSize(width: 200, height: 60))
        backButton.name = "BackButton"
        backButton.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        addChild(backButton)
        
        let backLabel = SKLabelNode(text: "BACK")
        backLabel.name = "BackButtonLabel"
        backLabel.fontName = "Helvetica-Bold"
        backLabel.fontSize = 24
        backLabel.fontColor = .white
        backLabel.verticalAlignmentMode = .center
        backButton.addChild(backLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        // Return to Main Menu
        if touchedNode.name == "BackButton" || touchedNode.name == "BackButtonLabel" {
            let menuScene = MainMenuScene(size: self.size)
            menuScene.scaleMode = .aspectFill
            self.view?.presentScene(menuScene, transition: SKTransition.crossFade(withDuration: 0.5))
        }
    }
}
