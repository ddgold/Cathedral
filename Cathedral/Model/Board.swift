//
//  Board.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

/// A game board build up of a 2d-array of tiles.
struct Board
{
    //MARK: - Properties
    /// The 2d-array of tiles that make up this board.
    private var tiles: [[Tile]]
    
    
    //MARK: - Initialization
    /// Initializes a new empty board.
    init()
    {
        tiles = [[Tile]]()
        
        for col in 0..<10
        {
            tiles.append([Tile]())
            for _ in 0..<10
            {
                tiles[col].append(Tile(owner: nil, piece: nil))
            }
        }
    }
    
    
    //MARK: - Subscript
    /// Retrieves or sets a tile from the board.
    ///
    /// - Parameter address: The desired tile's address on board.
    subscript(address: Address) -> Tile
    {
        get
        {
            return tiles[Int(address.col)][Int(address.row)]
        }
        set(newTile)
        {
            tiles[Int(address.col)][Int(address.row)] = newTile
        }
    }
    
    
    //MARK: - Descriptions
    /// Description of the board struct.
    static var description: String
    {
        return "Board"
    }
    
    /// Description of a particular board.
    var description: String
    {
        var description = " "
        for col in 0..<10
        {
            description += " " + col.description
        }
        
        for row in 0..<10
        {
            description += "\n" + row.description
            for col in 0..<10
            {
                description += " " + tiles[col][row].description
            }
        }
        return description
    }
}
