//
//  Deck.swift
//  L'HermitsRun
//
//  Created by Sérgio Oliveira on 22/04/2026.
//

import Foundation
import SpriteKit

class Deck {
    
    var deck : [Card] = []
    let allSuits = Suit.allCases
    let hermit: Hermit
    let cardSize: CGSize
    
    init(hermit: Hermit, cardSize: CGSize) {
        self.hermit = hermit
        self.cardSize = cardSize
        
        CreateTier(ranks: [.ace, .two, .three, .four])
        CreateTier(ranks: [.five, .six, .seven, .eight, .nine])
        CreateTier(ranks: [.ten, .jack, .queen, .king])
    }

    func CreateTier(ranks: [Rank]) {
        var tempDeck: [Card] = []
        
        for r in ranks {
            for s in Suit.allCases {
                let newCard = Card(rank: r, suit: s, size: cardSize)
                tempDeck.append(newCard)
            }
        }

        deck.append(contentsOf: tempDeck.shuffled())
    }

    func PrintTier() {
        // Simulate drawing 3 sets of 4 cards
        for setNumber in 1...13 {
            print("--- Draw Set \(setNumber) ---")
            let drawn = DrawNextSet()
            CardsToString(cards: drawn)
            for card in drawn {
                hermit.triggerCard(card: card)
            }
        }
    }
    
    func DrawNextSet() -> [Card] {
        var nextSet: [Card] = []
        for _ in 1...4 {
            let drawn = deck[0]
            deck.remove(at: 0)
            nextSet.append(drawn)
        }
        
        return nextSet;
    }
}

