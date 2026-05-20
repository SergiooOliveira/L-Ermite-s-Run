//
//  GameScene.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/04/2026.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameBoard: Board!
    
    override func didMove(to view: SKView) {
        self.anchorPoint = .zero
        
        let hermitSize = CGSize(width: 80, height: 80)
        let myHermit = Hermit(health: 100, size: hermitSize)
        
        // (Optional) Position the Hermit somewhere on the screen so you can see him!
        // For example, placing him in the top left corner:
        myHermit.position = CGPoint(x: 60, y: self.size.height - 60)
        myHermit.zPosition = 50
        
        
        gameBoard = Board(size: self.size, hermit: myHermit)
        addChild(gameBoard)
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
        
        // Grab everything under the user's tap
        let touchedNodes = self.nodes(at: location)
        
        // 1. Check if they pressed the Deal Button
        for node in touchedNodes {
            if let nodeName = node.name {
                if nodeName == "TopCellButton" || nodeName == "TopCellButtonLabel" {
                    print("Deal Button pressed")
                    gameBoard.dealOneCardToAllColumns()
                    return // Stop looking, we handled the button press
                }
            }
        }
        
        // That's it!
        // We DELETE all the old column-tapping logic.
        // We let the custom Card class handle its own dragging touches.
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
