//
//  Deck.swift
//  L'HermitsRun
//
//  Created by Sérgio Oliveira on 22/04/2026.
//

import Foundation


class Deck {
    
    var deck : [Card] = []
    let allSuits = Suit.allCases

    init() {
        CreateTier(ranks: [.two, .three, .four, .five])
        CreateTier(ranks: [.six, .seven, .eight, .nine, .ten])
        CreateTier(ranks: [.jack, .queen, .king, .ace])

        PrintTier()
    }

    func CreateTier(ranks: [Rank]) {
        var tempDeck: [Card] = []
        
        for r in ranks {
            for s in Suit.allCases {
                let newCard = Card(rank: r, suit: s)
                tempDeck.append(newCard)
            }
        }

        deck.append(contentsOf: tempDeck.shuffled())
    }

    func PrintTier() {
        // Simulate drawing 3 sets of 4 cards
        for setNumber in 1...13 {
            print("--- Draw Set \(setNumber) ---")
            for _ in 1...4 {
                if !deck.isEmpty {
                    let drawn = deck.removeFirst()
                    print("Revealed: \(drawn)")
                }
            }
        }
    }
}
