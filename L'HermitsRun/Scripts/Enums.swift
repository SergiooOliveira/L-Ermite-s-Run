//
//  Enums.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/04/2026.
//

import Foundation

enum Suit {
    case spades
    case hearts
    case diamonds
    case clubs
}

enum Rank {
    case ace
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king
    
    var value: Int {
        switch self {
        case .ace:
            return 1
        case .two:
            return 2
        case .three:
            return 3
        case .four:
            return 4
        case .five:
            return 5
        case .six:
            return 6
        case .seven:
            return 7
        case .eight:
            return 8
        case .nine:
            return 9
        case .ten:
            return 10
        case .jack, .queen, .king:
            return 11
        default
            return 0
        }
    }
}
