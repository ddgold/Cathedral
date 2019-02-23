//
//  Piece.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

/// A game piece that has been placed on the board.
struct Piece: Hashable
{
    //MARK: - Properties
    /// The owner of the piece.
    let owner: Owner
    /// The building type of the piece.
    let building: Building
    /// The direction the piece is facing.
    let direction: Direction
    /// The address the piece's origin.
    let address: Address
    /// The log entry for this piece.
    var log: String
    {
        return "\(building.log)\(direction.log)\(address.log)"
    }
    
    //MARK: - Functions
    /// Gets the set of address that this building covers.
    ///
    /// - Returns: Set of address covered.
    func addresses() -> Set<Address>
    {
        return building.blueprint(owner: owner, facing: direction, at: address)
    }
    
    
    //MARK: - Descriptions
    /// Description of the piece struct.
    static var description: String
    {
        return "Piece"
    }
    
    /// Description of a particular piece.
    var description: String
    {
        return "\(owner) \(building) facing \(direction) at \(address)"
    }
}
