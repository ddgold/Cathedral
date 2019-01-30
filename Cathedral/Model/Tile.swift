//
//  Tile.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

/// A single tile from a game board.
struct Tile: Equatable
{
    //MARK: - Properties
    /// The owner of the tile, nil if not built upon or claimed.
    var owner: Owner?
    /// The game piece built upon the tile, or nil if not built upon. Will set tile owner to piece owner.
    var piece: Piece?
    {
        didSet
        {
            if let piece = self.piece
            {
                owner = piece.owner
            }
        }
    }
    /// Whether or not a piece has been built on this tile.
    var isBuilt: Bool
    {
        return piece != nil
    }
    
    
    //MARK: - Descriptions
    /// Description of the tile struct.
    static var description: String
    {
        return "Tile"
    }
    
    /// Description of a particular tile.
    var description: String
    {
        if let owner = self.owner
        {
            switch owner
            {
            case .Church:
                if isBuilt
                {
                    return "C"
                }
                else
                {
                    return "c"
                }
            case .Light:
                if isBuilt
                {
                    return "L"
                }
                else
                {
                    return "l"
                }
            case .Dark:
                if isBuilt
                {
                    return "D"
                }
                else
                {
                    return "d"
                }
            }
        }
        else
        {
            return "."
        }
    }
}
