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
    
    /// The log entry for this direction.
    var log: String
    {
        switch self
        {
        case .north:
            return "n"
        case .east:
            return "e"
        case .south:
            return "s"
        case .west:
            return "w"
        }
    }
    
    
    //MARK: - Initialization
    /// Initializes a direction from a log entry.
    ///
    /// - Parameter log: The log entry.
    init?(_ log: String)
    {
        switch log
        {
        case "n":
            self = .north
        case "e":
            self = .east
        case "s":
            self = .south
        case "w":
            self = .west
        default:
            return nil
        }
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
