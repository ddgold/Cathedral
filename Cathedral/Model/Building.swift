//
//  Building.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

/// A building type.
enum Building: UInt8
{
    //MARK: - Values
    case Tavern
    case Stable
    case Inn
    case Bridge
    case Square
    case Abbey
    case Manor
    case Tower
    case Infirmary
    case Castle
    case Academy
    case Cathedral
    
    
    //MARK: - Properties
    /// Set of all player buildings.
    static var playerBuildings: Set<Building>
    {
        return [self.Tavern, self.Stable, self.Inn, self.Bridge, self.Square, self.Abbey, self.Manor, self.Tower, self.Infirmary, self.Castle, self.Academy]
    }
    
    /// Whether or not this building type is a player building, i.e. not the cathedral.
    var isPlayerBuilding: Bool
    {
        return (self != Building.Cathedral)
    }
    
    /// The number if tiles wide this building type covers.
    var width: UInt8
    {
        switch self
        {
        case .Tavern:
            return 1
        case .Stable:
            return 1
        case .Inn:
            return 2
        case .Bridge:
            return 1
        case .Square:
            return 2
        case .Abbey:
            return 2
        case .Manor:
            return 2
        case .Tower:
            return 3
        case .Infirmary:
            return 3
        case .Castle:
            return 2
        case .Academy:
            return 3
        case .Cathedral:
            return 3
        }
    }
    
    /// The number of tiles tall this building type covers.
    var height: UInt8
    {
        switch self
        {
        case .Tavern:
            return 1
        case .Stable:
            return 2
        case .Inn:
            return 2
        case .Bridge:
            return 3
        case .Square:
            return 2
        case .Abbey:
            return 3
        case .Manor:
            return 3
        case .Tower:
            return 3
        case .Infirmary:
            return 3
        case .Castle:
            return 3
        case .Academy:
            return 3
        case .Cathedral:
            return 4
        }
    }
    
    /// The number of tiles this building type covers.
    var size: UInt8
    {
        switch self
        {
        case .Tavern:
            return 1
        case .Stable:
            return 2
        case .Inn:
            return 3
        case .Bridge:
            return 3
        case .Square:
            return 4
        case .Abbey:
            return 4
        case .Manor:
            return 4
        case .Tower:
            return 5
        case .Infirmary:
            return 5
        case .Castle:
            return 5
        case .Academy:
            return 5
        case .Cathedral:
            return 6
        }
    }
    
    
    //MARK: - Functions
    /// Builds the blueprints for this building type based on owner, direction, and address.
    ///
    /// - Parameters:
    ///   - owner: The owner of the building.
    ///   - direction: The direction of the building.
    ///   - address: The origin of the building.
    /// - Returns: A set of addresses that make up the blueprint.
    func blueprint(owner: Owner, facing direction: Direction, at address: Address) -> Set<Address>
    {
        assert(owner.isPlayerOwner == self.isPlayerBuilding, "Can't get blueprint for invalid Piece " + owner.description + " " + self.description)
        
        // Get the base blueprint base on owner and building type
        let base: Set<Address>
        switch self
        {
        case .Tavern:
            base = [Address(0, 0)]
        case .Stable:
            base = [Address(0, 0),
                    Address(0, 1)]
        case .Inn:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(1, 0)]
        case .Bridge:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(0, 2)]
        case .Square:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(1, 0),
                    Address(1, 1)]
        case .Abbey:
            if (owner == .Light)
            {
                base = [Address(0, 0),
                        Address(0, 1),
                        Address(1, 1),
                        Address(1, 2)]
            }
            else
            {
                base = [Address(0, 1),
                        Address(0, 2),
                        Address(1, 0),
                        Address(1, 1)]
            }
        case .Manor:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(0, 2),
                    Address(1, 1)]
        case .Tower:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(1, 1),
                    Address(1, 2),
                    Address(2, 2)]
        case .Infirmary:
            base = [Address(0, 1),
                    Address(1, 0),
                    Address(1, 1),
                    Address(1, 2),
                    Address(2, 1)]
        case .Castle:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(0, 2),
                    Address(1, 0),
                    Address(1, 2)]
        case .Academy:
            if (owner == .Light)
            {
                base = [Address(0, 1),
                        Address(1, 0),
                        Address(1, 1),
                        Address(1, 2),
                        Address(2, 2)]
            }
            else
            {
                base = [Address(0, 2),
                        Address(1, 0),
                        Address(1, 1),
                        Address(1, 2),
                        Address(2, 1)]
            }
        case .Cathedral:
            base = [Address(0, 1),
                    Address(1, 0),
                    Address(1, 1),
                    Address(1, 2),
                    Address(1, 3),
                    Address(2, 1)]
        }
        
        // Rotate and translate blueprint based on direction and origin
        var final = Set<Address>()
        base.forEach { (offset) in
            let rotated = offset.rotated(direction)
            final.insert(Address(address.col + rotated.col, address.row + rotated.row))
        }
        
        return final
    }
    
    
    //MARK: - Descriptions
    /// Description of the building enum.
    static var description: String
    {
        return "Building"
    }
    
    /// Description of a particular building.
    var description: String
    {
        switch self
        {
        case .Tavern:
            return "Tavern"
        case .Stable:
            return "Stable"
        case .Inn:
            return "Inn"
        case .Bridge:
            return "Bridge"
        case .Square:
            return "Square"
        case .Abbey:
            return "Abbey"
        case .Manor:
            return "Manor"
        case .Tower:
            return "Tower"
        case .Infirmary:
            return "Infirmary"
        case .Castle:
            return "Castle"
        case .Academy:
            return "Academy"
        case .Cathedral:
            return "Cathedral"
        }
    }
}
