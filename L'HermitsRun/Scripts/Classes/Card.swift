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

    // extension Card: CustomStringConvertible {
    // var description: String {
    //     return "\(rank) (\(rank.value)) of \(suit)"
    // }
}