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
    case North
    case East
    case South
    case West
    
    
    //MARK: - Properties
    /// The set of all cardinal directions.
    static var cardinalDirections: Set<Direction>
    {
        return [self.North, self.East, self.South, self.West]
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
        case .North:
            return "North"
        case .East:
            return "East"
        case .South:
            return "South"
        case .West:
            return "West"
        }
    }
}
