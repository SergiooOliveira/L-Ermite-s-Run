//
//  Hermit.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/04/2026.
//

import Foundation


class Hermit {
    
    var health: Int
    var armor: Int
    var damage: Int
    
    init(health: Int, armor: Int, damage: Int) {
        self.health = health
        self.armor = armor
        self.damage = damage
    }

    /*
    init(config: Int) {
    }
    */
    
    func triggerCard(card: Card) {
        card.triggerEffect()
        
    }
}
