//
//  LargestFirstComputer.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/18/20.
//  Copyright © 2020 Doug Goldstein. All rights reserved.
//

import Foundation

/// A computer player object that builds randomly.
class LargestFirstComputer: Computer
{
    /// The player type's ID.
    static var id: String
    {
        return "LargestFirstComputer"
    }
    
    /// The game.
    private let game: Game
    /// The owner.
    private let owner: Owner
    
    /// The name of the player.
    var name: String
    {
        return "Largest First Computer"
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
            assert(owner == .light)
            
            return randomLocation(owner: nextOwner, building: .cathedral)
        }
        else
        {
            assert(nextOwner == owner)
            assert(game.canMakeMove(owner))
            
            var largestSize: UInt8 = 0
            var largestBuildings = Set<Building>()
            
            
            for (building,canBuild) in game.unbuiltBuildings(for: owner)
            {
                if canBuild && (building.size >= largestSize)
                {
                    if building.size > largestSize
                    {
                        largestSize = building.size
                        largestBuildings.removeAll()
                    }
                    
                    largestBuildings.insert(building)
                }
            }
            
            assert(!largestBuildings.isEmpty)
            
            return randomLocation(owner: owner, building: largestBuildings.randomElement()!)
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
