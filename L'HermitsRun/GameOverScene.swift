//
//  GameOverScene.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/05/2026.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var finalScore: Int = 0
    
    // Custom initializer to catch the gold from the Board!
    init(size: CGSize, score: Int) {
        self.finalScore = score
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .darkGray
        
        let currentHighScore = UserDefaults.standard.integer(forKey: "HighestScore") // Defaults to 0 if none exists
        if finalScore > currentHighScore {
            UserDefaults.standard.set(finalScore, forKey: "HighestScore")
        }
        
        // 1. Victory Title
        let titleLabel = SKLabelNode(text: "VICTORY!")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .systemGreen
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)
        
        // 2. Final Score Display
        let scoreLabel = SKLabelNode(text: "Final Gold: \(finalScore)")
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .systemYellow
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        addChild(scoreLabel)
        
        // 3. Main Menu Button
        let menuButton = SKSpriteNode(color: .systemBlue, size: CGSize(width: 200, height: 60))
        menuButton.name = "MenuButton"
        menuButton.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        addChild(menuButton)
        
        let menuLabel = SKLabelNode(text: "MAIN MENU")
        menuLabel.name = "MenuButtonLabel"
        menuLabel.fontName = "Helvetica-Bold"
        menuLabel.fontSize = 24
        menuLabel.fontColor = .white
        menuLabel.verticalAlignmentMode = .center
        menuButton.addChild(menuLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchedNode = atPoint(touch.location(in: self))
        
        if touchedNode.name == "MenuButton" || touchedNode.name == "MenuButtonLabel" {
            let menuScene = MainMenuScene(size: self.size)
            menuScene.scaleMode = .aspectFill
            self.view?.presentScene(menuScene, transition: SKTransition.crossFade(withDuration: 0.5))
        }
    }
}
