//
//  Direction.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

/// A cardinal direction on the game board.
enum Direction: UInt8
{
    //MARK: - Values
    case north
    case east
    case south
    case west
    
    
    //MARK: - Properties
    /// The set of all cardinal directions.
    static var cardinalDirections: Set<Direction>
    {
        return [self.north, self.east, self.south, self.west]
    }
    
    
    //MARK: - Descriptions
    /// Description of the direction enum.
    static var description: String
    {
        return "Direction"
    }
    
    /// Description of a particular direction.
    var description: String
    {
        switch self
        {
        case .north:
            return "North"
        case .east:
            return "East"
        case .south:
            return "South"
        case .west:
            return "West"
        }
    }
}
