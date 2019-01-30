//
//  Owner.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

/// A possible game piece owner, including player owners, i.e. light and dark, as well as, the cathedral owner, i.e. church.
enum Owner: UInt8
{
    //MARK: - Values
    case Light
    case Dark
    case Church
    
    
    //MARK: - Properties
    /// Whether or not tbis owner is a player owner, i.e. light or dark.
    var isPlayerOwner: Bool
    {
        return (self != Owner.Church)
    }
    
    /// The oppenent of this owner. Note, only player owners have oppenents.
    var opponent: Owner
    {
        switch self
        {
        case .Light:
            return Owner.Dark
        case .Dark:
            return Owner.Light
        case .Church:
            assert(false, "Only player Owners have opponents")
        }
    }
    
    
    //MARK: - Descriptions
    /// Description of the piece enum.
    static var description: String
    {
        return "Owner"
    }
    
    /// Description of a particular owner.
    var description: String
    {
        switch self
        {
        case .Light:
            return "Light"
        case .Dark:
            return "Dark"
        case .Church:
            return "Church"
        }
    }
}
