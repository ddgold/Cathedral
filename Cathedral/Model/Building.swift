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
    case tavern
    case stable
    case inn
    case bridge
    case square
    case abbey
    case manor
    case tower
    case infirmary
    case castle
    case academy
    case cathedral
    
    
    //MARK: - Properties
    /// Set of all player buildings.
    static var playerBuildings: Set<Building>
    {
        return [self.tavern, self.stable, self.inn, self.bridge, self.square, self.abbey, self.manor, self.tower, self.infirmary, self.castle, self.academy]
    }
    
    /// Whether or not this building type is a player building, i.e. not the cathedral.
    var isPlayerBuilding: Bool
    {
        return (self != Building.cathedral)
    }
    
    /// The number if tiles wide this building type covers.
    private var width: UInt8
    {
        switch self
        {
        case .tavern:
            return 1
        case .stable:
            return 1
        case .inn:
            return 2
        case .bridge:
            return 1
        case .square:
            return 2
        case .abbey:
            return 2
        case .manor:
            return 2
        case .tower:
            return 3
        case .infirmary:
            return 3
        case .castle:
            return 2
        case .academy:
            return 3
        case .cathedral:
            return 3
        }
    }
    
    /// The number of tiles tall this building type covers.
    private var height: UInt8
    {
        switch self
        {
        case .tavern:
            return 1
        case .stable:
            return 2
        case .inn:
            return 2
        case .bridge:
            return 3
        case .square:
            return 2
        case .abbey:
            return 3
        case .manor:
            return 3
        case .tower:
            return 3
        case .infirmary:
            return 3
        case .castle:
            return 3
        case .academy:
            return 3
        case .cathedral:
            return 4
        }
    }
    
    /// The number of tiles this building type covers.
    var size: UInt8
    {
        switch self
        {
        case .tavern:
            return 1
        case .stable:
            return 2
        case .inn:
            return 3
        case .bridge:
            return 3
        case .square:
            return 4
        case .abbey:
            return 4
        case .manor:
            return 4
        case .tower:
            return 5
        case .infirmary:
            return 5
        case .castle:
            return 5
        case .academy:
            return 5
        case .cathedral:
            return 6
        }
    }
    
    /// The log entry for this building.
    var log: String
    {
        switch self
        {
        case .tavern:
            return "TA"
        case .stable:
            return "ST"
        case .inn:
            return "IN"
        case .bridge:
            return "BR"
        case .square:
            return "SQ"
        case .abbey:
            return "AB"
        case .manor:
            return "MA"
        case .tower:
            return "TO"
        case .infirmary:
            return "IF"
        case .castle:
            return "CS"
        case .academy:
            return "AC"
        case .cathedral:
            return "CA"
        }
    }
    
    
    //MARK: - Initialization
    /// Initializes a building from a log entry.
    ///
    /// - Parameter log: The log entry.
    init?(_ log: String)
    {
        switch log
        {
        case "TA":
            self = .tavern
        case "ST":
            self = .stable
        case "IN":
            self = .inn
        case "BR":
            self = .bridge
        case "SQ":
            self = .square
        case "AB":
            self = .abbey
        case "MA":
            self = .manor
        case "TO":
            self = .tower
        case "IF":
            self = .infirmary
        case "CS":
            self = .castle
        case "AC":
            self = .academy
        case "CA":
            self = .cathedral
        default:
            return nil
        }
    }
    
    
    //MARK: - Functions
    /// Builds the blueprints for this building type based on owner, direction, and address.
    ///
    /// - Parameters:
    ///   - owner: The owner of the building.
    ///   - direction: The direction of the building.
    ///   - address: The origin of the building. Defaults to (0, 0).
    /// - Returns: A set of addresses that make up the blueprint.
    func blueprint(owner: Owner, facing direction: Direction, at address: Address = Address(0, 0)) -> Set<Address>
    {
        assert(owner.isPlayer == self.isPlayerBuilding, "Can't get blueprint for \(owner) \(self)")
        
        // Get the base blueprint base on owner and building type
        let base: Set<Address>
        switch self
        {
        case .tavern:
            base = [Address(0, 0)]
        case .stable:
            base = [Address(0, 0),
                    Address(0, 1)]
        case .inn:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(1, 0)]
        case .bridge:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(0, 2)]
        case .square:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(1, 0),
                    Address(1, 1)]
        case .abbey:
            if (owner == .light)
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
        case .manor:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(0, 2),
                    Address(1, 1)]
        case .tower:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(1, 1),
                    Address(1, 2),
                    Address(2, 2)]
        case .infirmary:
            base = [Address(0, 1),
                    Address(1, 0),
                    Address(1, 1),
                    Address(1, 2),
                    Address(2, 1)]
        case .castle:
            base = [Address(0, 0),
                    Address(0, 1),
                    Address(0, 2),
                    Address(1, 0),
                    Address(1, 2)]
        case .academy:
            if (owner == .light)
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
        case .cathedral:
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
    
    /// Get the tile width and height for this building facing a given direction.
    ///
    /// - Parameter direction: The direction.
    /// - Returns: A tuple, where the fist element is the width, and the second element is the height.
    func dimensions(direction: Direction) -> (width: Int8, height: Int8)
    {
        let width: Int8
        let height: Int8
        
        if (direction == .north) || (direction == .south)
        {
            width = Int8(self.width)
            height = Int8(self.height)
        }
        else
        {
            width = Int8(self.height)
            height = Int8(self.width)
        }
        
        return (width: width, height: height)
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
        case .tavern:
            return "Tavern"
        case .stable:
            return "Stable"
        case .inn:
            return "Inn"
        case .bridge:
            return "Bridge"
        case .square:
            return "Square"
        case .abbey:
            return "Abbey"
        case .manor:
            return "Manor"
        case .tower:
            return "Tower"
        case .infirmary:
            return "Infirmary"
        case .castle:
            return "Castle"
        case .academy:
            return "Academy"
        case .cathedral:
            return "Cathedral"
        }
    }
}
