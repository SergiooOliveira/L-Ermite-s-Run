//
//  Extensions.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 06/05/2026.
//

import Foundation
import UIKit

func CardsToString(cards: [Card]) {
    for card in cards {
        print("\(card.rank) (\(card.rank.value)) of \(card.suit)")
    }
}

extension Suit {
    var emoji: String {
        switch self {
        case .hearts: return "♥️"
        case .diamonds: return "♦️"
        case .clubs: return "♣️"
        case .spades: return "♠️"
        }
    }
    
    var displayColor: UIColor {
        switch self {
        case .hearts, .diamonds: return .systemRed
        case .clubs, .spades: return .black
        }
    }
}
