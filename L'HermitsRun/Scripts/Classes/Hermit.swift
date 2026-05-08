//
//  Hermit.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/04/2026.
//

import Foundation


class Hermit {
    
    var health: Int
    var maxHealth: Int
    var armor: Int
    var damage: Int
    
    init(health: Int, armor: Int, damage: Int) {
        self.health = health
        self.maxHealth = health
        self.armor = armor
        self.damage = damage
        
        var _ : Deck = Deck(hermit: self)
    }

    /*init(modifier: Int) {
        self.health
    }*/
    
    func triggerCard(card: Card) {
        card.triggerEffect(hermit: self)
    }
}
