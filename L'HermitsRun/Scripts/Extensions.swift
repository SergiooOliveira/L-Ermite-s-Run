//
//  Extensions.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 06/05/2026.
//

import Foundation

func CardsToString(cards: [Card]) {
    for card in cards {
        print("\(card.rank) (\(card.rank.value)) of \(card.suit)")
    }
}
