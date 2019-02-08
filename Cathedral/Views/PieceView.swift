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
    
    /// The owner of the piece.
    let owner: Owner
    /// The building type of the piece.
    let building: Building
    
    
    /// The current rotation of the piece.
    private(set) var angle: CGFloat = 0
    
    /// The size of a tile set by controller.
    private var tileSize: CGFloat
    {
        didSet(newValue)
        {
            resetTileSize(newValue)
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
        
        let imageName = "\(owner.description)_\(building.description)"
        guard let imageObject = UIImage(named: imageName) else
        {
            fatalError("Failed to find image: '\(imageName)'")
        }
        
        super.init(image: imageObject)
        self.isUserInteractionEnabled = true
        
        switch direction
        {
        case .north:
            break
        case .east:
            rotate(to: CGFloat.pi / 2)
        case .south:
            rotate(to: CGFloat.pi)
        case .west:
            rotate(to: 3 * CGFloat.pi / 2)
        }
        
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
    
    /// Move the piece to a new position.
    ///
    /// - Parameter newPosition: The new position.
    func move(to newPosition: CGPoint)
    {
        self.frame.origin = newPosition
    }
    
    /// Rotate the piece to a new angle.
    ///
    /// - Parameter newAngle: The new angle.
    func rotate(to newAngle: CGFloat)
    {
        angle = newAngle
        transform = CGAffineTransform(rotationAngle: newAngle)
    }
    
    /// Snap the piece to a cardinal direction.
    ///
    /// - Returns: The snapped direction of the piece.
    func snapToDirection() -> Direction
    {
        // Calculate the distance to nearest half-pi
        let halfPi = CGFloat.pi / 2
        let remainder = angle.truncatingRemainder(dividingBy: halfPi)
        
        // Remove the remainder to get to nearest half-pi
        if remainder < -(halfPi / 2)
        {
            rotate(to: angle - remainder - halfPi)
        }
        else if remainder > (halfPi / 2)
        {
            rotate(to: angle - remainder + halfPi)
        }
        else
        {
            rotate(to: angle - remainder)
        }
        
        // Count the number of half-pis and add 4 until its positive
        var halfPis = Int8((angle / halfPi).rounded())
        while halfPis < 0
        {
            halfPis += 4
        }
        
        // Mod 4 to get the direction
        return Direction(rawValue: UInt8(halfPis % 4))!
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
