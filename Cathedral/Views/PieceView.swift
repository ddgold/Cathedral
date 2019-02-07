//
//  PieceView.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/30/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit

class PieceView: UIImageView
{
    //MARK: - Properties
    /// The size of a tile set by controller.
    private var tileSize: CGFloat
    {
        didSet(newValue)
        {
            resetTileSize(newValue)
        }
    }
    
    /// The owner of the piece.
    let owner: Owner
    /// The building type of the piece.
    let building: Building
    /// The direction the piece is facting.
    let direction: Direction
    
    /// The piece's width in count of tiles.
    var width: UInt8
    {
        if (direction == .east) || (direction == .west)
        {
            return building.height
        }
        else
        {
            return building.width
        }
    }
    
    /// The piece's height in count of tiles.
    var height: UInt8
    {
        if (direction == .north) || (direction == .south)
        {
            return building.height
        }
        else
        {
            return building.width
        }
    }
    
    
    //MARK: - Initialization
    /// Initialize a new piece view.
    ///
    /// - Parameters:
    ///   - owner: The owner.
    ///   - building: The building type.
    ///   - direction: The direction the piece is face.
    ///   - tileSize: The tile size.
    init(owner: Owner, building: Building, direction: Direction = .north, tileSize: CGFloat)
    {
        self.tileSize = tileSize
        
        self.owner = owner
        self.building = building
        self.direction = direction
        
        let imageName = "\(owner.description)_\(building.description)"
        guard let imageObject = UIImage(named: imageName) else
        {
            fatalError("Failed to find image: '\(imageName)'")
        }
        
        super.init(image: imageObject)
        self.isUserInteractionEnabled = true
        
        resetTileSize(tileSize)
    }
    
    /// Unsupported decoder initilizer.
    ///
    /// - Parameter aDecoder: The decoder.
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Functions
    /// Determines if a point is within the bounds of this piece.
    ///
    /// - Parameter point: The point.
    /// - Returns: Whether or not the point is in the piece.
    func contains(point: CGPoint) -> Bool
    {
        let col = Int8((point.x / tileSize).rounded(.down))
        let row = Int8((point.y / tileSize).rounded(.down))
        // Always get blueprint relateive to North because point is address inside view
        return building.blueprint(owner: owner, facing: .north).contains(where: { address in
            return (address.col == col) && (address.row == row)
        })
    }
    
    /// Reset the tile size to a new value.
    ///
    /// - Parameter tileSize: The new tile size.
    private func resetTileSize(_ tileSize: CGFloat)
    {
        let size = CGSize(width: tileSize * CGFloat(building.width), height: tileSize * CGFloat(building.height))
        self.frame = CGRect(origin: self.frame.origin, size: size)
    }
}
