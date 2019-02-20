//
//  PieceView.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/30/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit


/// A building piece view.
class PieceView: UIImageView
{
    //MARK: - Properties
    /// The owner of the piece.
    let owner: Owner
    
    /// The building type of the piece.
    let building: Building
    
    /// The state of the piece.
    var state: State
    {
        didSet
        {
            switch state
            {
            case .Standard:
                colorFilter.isHidden = true
            case .Success:
                colorFilter.backgroundColor =  UIColor(displayP3Red: 0, green: 1, blue: 0, alpha: 0.3)
                colorFilter.isHidden = false
            case .Failure:
                colorFilter.backgroundColor =  UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.3)
                colorFilter.isHidden = false
            }
        }
    }
    
    /// The color filter for highlighting the piece.
    private var colorFilter: UIView
    
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
        self.state = .Standard
        
        let imageName = "\(owner.description)_\(building.description)"
        guard let imageObject = UIImage(named: imageName) else
        {
            fatalError("Failed to find image: '\(imageName)'")
        }
        
        colorFilter = UIView()
        
        super.init(image: imageObject)
        self.isUserInteractionEnabled = true
        
        // Set size
        resetTileSize(tileSize)
        
        // Add color filter
        colorFilter.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        colorFilter.isHidden = true
        let maskView = UIImageView(image: imageObject)
        maskView.frame = colorFilter.frame
        colorFilter.mask = maskView
        addSubview(colorFilter)
        
        // Set rotation based on direction
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
    
    
    /// Snap the piece to a point along the grid.
    ///
    /// - Returns: The snapped address of the piece.
    func snapToGrid() -> Address
    {
        var point = self.frame.origin
        point.x = point.x.snap(to: tileSize)
        point.y = point.y.snap(to: tileSize)
        move(to: point)
        
        return point.toAddress(tileSize: tileSize)
    }
    
    /// Rotate the piece to a new angle.
    ///
    /// - Parameter newAngle: The new angle.
    func rotate(to newAngle: CGFloat)
    {
        self.angle = newAngle
        transform = CGAffineTransform(rotationAngle: newAngle)
    }
    
    /// Snap the piece to a cardinal direction.
    ///
    /// - Returns: The snapped direction of the piece.
    func snapToDirection() -> Direction
    {
        // Snap to the nearest half-pi
        let halfPi = CGFloat.pi / 2
        let angle = self.angle.snap(to: halfPi)
        rotate(to: angle)
        
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
    
    
    //MARK: - State Enum
    enum State: UInt8
    {
        /// Standard, unhighlighted.
        case Standard
        /// Highlighted in green.
        case Success
        /// Highlighted in red.
        case Failure
    }
}
