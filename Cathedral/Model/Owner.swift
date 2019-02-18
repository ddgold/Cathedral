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
    case light
    case dark
    case church
    
    
    //MARK: - Properties
    /// Whether or not tbis owner is a player owner, i.e. light or dark.
    var isPlayer: Bool
    {
        return (self != Owner.church)
    }
    
    /// The oppenent of this owner. Note, only player owners have oppenents.
    var opponent: Owner
    {
        switch self
        {
        case .light:
            return Owner.dark
        case .dark:
            return Owner.light
        case .church:
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
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .church:
            return "Church"
        }
    }
}
