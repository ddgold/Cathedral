//
//  Address.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

/// A 2-dimensional tile address.
struct Address: Hashable
{
    //MARK: - Properties
    /// The column position.
    let col: Int8
    /// The row position.
    let row: Int8
    
    
    //MARK: - Initialization
    /// Initializes a specified address.
    ///
    /// - Parameters:
    ///   - col: The column position.
    ///   - row: The row position.
    init(_ col: Int8, _ row: Int8)
    {
        self.col = col
        self.row = row
    }
    
    
    //MARK: - Functions
    /// Get the set of addresses neighboring this address.
    ///
    /// - Returns: Set of the neighboring addresses.
    func neighbors() -> Set<Address>
    {
        return [Address(col    , row - 1), // North
            Address(col + 1, row - 1), // Northeast
            Address(col + 1, row    ), // East
            Address(col + 1, row + 1), // Southeast
            Address(col    , row + 1), // South
            Address(col - 1, row + 1), // Southwest
            Address(col - 1, row    ), // West
            Address(col - 1, row - 1)] // Northwest
    }
    
    /// Builds an address that is this address rotated to a specified direction.
    ///
    /// - Parameter direction: Desired direction.
    /// - Returns: Address rotated to direction.
    func rotated(_ direction: Direction) -> Address
    {
        switch direction
        {
        case .North:
            return Address(col,row)
        case .East:
            return Address(-row,col)
        case .South:
            return Address(-col,-row)
        case .West:
            return Address(row,-col)
        }
    }
    
    
    //MARK: - Descriptions
    /// Description of the address struct.
    static var description: String
    {
        return "Address"
    }
    
    /// Description of a particular address.
    var description: String
    {
        var description: String
        if (col < 0) || (col > 9)
        {
            description = col.description
        }
        else
        {
            description = " " + col.description
        }
        description += ","
        if (row < 0) || (row > 9)
        {
            description += row.description
        }
        else
        {
            description += " " + row.description
        }
        return description
    }
}
