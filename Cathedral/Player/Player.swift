//
//  Player.swift
//  Cathedral
//
//  Created by Doug Goldstein on 3/8/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation


//MARK: - PlayerType
/// Collection of player types.
struct PlayerTypes {
    /// Private initilizer so no instance can be made.
    private init() { }
    
    /// Array of all player type options.
    static var options: [Player.Type] {
        return [
            LocalHuman.self,
            RandomComputer.self,
            LargestFirstComputer.self
        ]
    }
    
    /// Get player type for a given id.
    static subscript(id: String) -> Player.Type {
        for type in options {
            if type.id == id {
                return type
            }
        }
        fatalError("Unkown player id: \(id)")
    }
}



//MARK: - Player
/// The core player protocol.
protocol Player {
    /// The player type's ID.
    static var id: String { get }
    
    /// The name of the player
    var name: String { get }
    
    /// Initializes a new player.
    ///
    /// - Parameters:
    ///   - game: The player's game.
    ///   - owner: The owner, must be light or dark.
    init (game: Game, owner: Owner)
}



/// The computer player protocol.
protocol Computer: Player {
    /// Determines the computer's next move.
    ///
    /// - Returns: The piece to build.
    func nextMove() -> Piece
}
