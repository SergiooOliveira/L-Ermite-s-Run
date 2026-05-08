//
//  Card.swift
//  L'HermitsRun
//
//  Created by Sérgio Oliveira on 22/04/2026.
//

import Foundation

class Card {
    
    var rank : Rank
    var suit : Suit
    var isFaceUp: Bool = false

    init(rank : Rank, suit : Suit) {
        self.rank = rank
        self.suit = suit
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
