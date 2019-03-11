//
//  Player.swift
//  Cathedral
//
//  Created by Doug Goldstein on 3/8/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

//MARK: - Player
/// The core player protocol.
protocol Player
{
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


/// Gets a player type from an ID
///
/// - Parameter id: The player type ID.
/// - Returns: The player type.
func PlayerType(_ id: String) -> Player.Type
{
    switch id
    {
    case LocalHuman.id:
        return LocalHuman.self
        
    case RandomComputer.id:
        return RandomComputer.self
        
    default:
        fatalError("Unknown player type id: \(id)")
    }
}



//MARK: - Human
/// The human player protocol.
protocol Human: Player
{
    
}


/// A local human player object.
class LocalHuman: Human
{
    /// The player type's ID.
    static var id: String
    {
        return "LocalHuman"
    }
    
    /// The owner.
    private let owner: Owner
    
    /// The name of the player.
    var name: String
    {
        return owner.description
    }
    
    /// Initializes a new local human player.
    ///
    /// - Parameters:
    ///   - game: The player's game.
    ///   - owner: The owner, must be light or dark.
    required init(game: Game, owner: Owner)
    {
        self.owner = owner
    }
}



//MARK: - Computer
/// The computer player protocol.
protocol Computer: Player
{
    /// Determines the computer's next move.
    ///
    /// - Returns: The piece to build.
    func nextMove() -> Piece
}


/// A computer player object that builds randomly.
class RandomComputer: Computer
{
    /// The player type's ID.
    static var id: String
    {
        return "RandomComputer"
    }
    
    /// The game.
    private let game: Game
    /// The owner.
    private let owner: Owner
    
    /// The name of the player.
    var name: String
    {
        return "Random Computer"
    }
    
    /// Initializes a new random computer player.
    ///
    /// - Parameters:
    ///   - game: The player's game.
    ///   - owner: The owner, must be light or dark.
    required init (game: Game, owner: Owner)
    {
        self.game = game
        self.owner = owner
    }
    
    /// Determines the computer's next random move.
    ///
    /// - Returns: The piece to build.
    func nextMove() -> Piece
    {
        guard let nextOwner = game.nextTurn else
        {
            fatalError()
        }
        
        if (nextOwner == .church)
        {
            return randomLocation(owner: nextOwner, building: .cathedral)
        }
        else
        {
            assert(nextOwner == owner)
            assert(game.canMakeMove(owner))
            
            let unbuildBuildings = game.unbuiltBuildings(for: owner)
            
            while true
            {
                let (randomBuilding,canBuild) = unbuildBuildings.randomElement()!
                if canBuild
                {
                    return randomLocation(owner: nextOwner, building: randomBuilding)
                }
            }
        }
    }
    
    /// Finds a valid location, address and direction, to build the piece.
    ///
    /// - Parameters:
    ///   - owner: The owner.
    ///   - building: The building type.
    /// - Returns: The piece to build.
    private func randomLocation(owner: Owner, building: Building) -> Piece
    {
        while true
        {
            let randomDirection =  Direction.cardinalDirections.randomElement()!
            let randomAddress = Address(Int8.random(in: 0 ..< 10), Int8.random(in: 0 ..< 10))
            
            if game.canBuildBuilding(building, for: owner, facing: randomDirection, at: randomAddress)
            {
                return Piece(owner: owner, building: building, direction: randomDirection, address: randomAddress)
            }
        }
    }
}
