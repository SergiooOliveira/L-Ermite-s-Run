//
//  Enums.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 22/04/2026.
//

import Foundation

enum Suit : CaseIterable {
    case spades
    case hearts
    case diamonds
    case clubs
}

enum Rank : CaseIterable {
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
        }
    }
}

extension Rank {
    static func from(value: Int) -> Rank {
        switch value {
        case 1: return .ace
        case 2: return .two
        case 3: return .three
        case 4: return .four
        case 5: return .five
        case 6: return .six
        case 7: return .seven
        case 8: return .eight
        case 9: return .nine
        case 10: return .ten
        default: return .jack // Catches 11+
        }
    }
}
