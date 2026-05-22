//
//  MainMenuScene.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/05/2026.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .darkGray
        
        // --- The Title ---
        let titleLabel = SKLabelNode(text: "THE HERMIT")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .systemYellow
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)
        
        // --- The Play Button ---
        let playButton = SKSpriteNode(color: .systemGreen, size: CGSize(width: 200, height: 60))
        playButton.name = "PlayButton"
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        addChild(playButton)
        
        let playLabel = SKLabelNode(text: "PLAY")
        playLabel.name = "PlayButtonLabel"
        playLabel.fontName = "Helvetica-Bold"
        playLabel.fontSize = 24
        playLabel.fontColor = .white
        playLabel.verticalAlignmentMode = .center
        playLabel.position = CGPoint(x: 0, y: 0) // Centered inside the button
        playButton.addChild(playLabel)
        
        // --- The Rules Button ---
        let rulesButton = SKSpriteNode(color: .systemBlue, size: CGSize(width: 200, height: 60))
        rulesButton.name = "RulesButton"
        rulesButton.position = CGPoint(x: size.width / 2, y: size.height * 0.30)
        addChild(rulesButton)
        
        let rulesLabel = SKLabelNode(text: "RULES")
        rulesLabel.name = "RulesButtonLabel"
        rulesLabel.fontName = "Helvetica-Bold"
        rulesLabel.fontSize = 24
        rulesLabel.fontColor = .white
        rulesLabel.verticalAlignmentMode = .center
        rulesButton.addChild(rulesLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        // If they tap the button or the text inside it, launch the game!
        if touchedNode.name == "PlayButton" || touchedNode.name == "PlayButtonLabel" {
            launchGame()
        }
        else if touchedNode.name == "RulesButton" || touchedNode.name == "RulesButtonLabel" {
            let rulesScene = RulesScene(size: self.size)
            rulesScene.scaleMode = .aspectFill
            self.view?.presentScene(rulesScene, transition: SKTransition.crossFade(withDuration: 0.5))
        }
    }
    
    private func launchGame() {
        // Creates a fresh instance of your GameScene
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .aspectFill
        
        // Adds a smooth 1-second crossfade transition
        let transition = SKTransition.crossFade(withDuration: 1.0)
        
        self.view?.presentScene(gameScene, transition: transition)
    }
}
