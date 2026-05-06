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
    
    func triggerEffect() {
        switch self.suit {
        case .clubs:
            // Trigger clubs
            clubEffect(value: self.rank.value)
        case .diamonds:
            // Trigger diamond
            diamondsEffect(value: self.rank.value)
        case .hearts:
            // Trigger hearts
            heartsEffect(value: self.rank.value)
        case .spades:
            // Trigger spades
            spadesEffect(value: self.rank.value)
        }
    }
    
    private func clubEffect(value: Int) {
        // Armor
    }
    
    private func diamondsEffect(value: Int) {
        // Take damage
    }
    
    private func heartsEffect(value: Int) {
        // Heal
    }
    
    private func spadesEffect(value: Int) {
        // Damage
    }
}
