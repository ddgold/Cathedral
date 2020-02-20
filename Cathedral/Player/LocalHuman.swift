//
//  LocalHuman.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/18/20.
//  Copyright © 2020 Doug Goldstein. All rights reserved.
//

import Foundation

/// A local human player object.
class LocalHuman: Player {
    /// The player type's ID.
    static var id: String {
        return "LocalHuman"
    }
    
    /// The owner.
    private let owner: Owner
    
    /// The name of the player.
    var name: String {
        return "\(owner.description) Player"
    }
    
    /// Initializes a new local human player.
    ///
    /// - Parameters:
    ///   - game: The player's game.
    ///   - owner: The owner, must be light or dark.
    required init(game: Game, owner: Owner) {
        self.owner = owner
    }
}
