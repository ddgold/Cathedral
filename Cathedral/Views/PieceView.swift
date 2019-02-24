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
    
    /// The direction the piece is facing.
    private(set) var direction: Direction?
    
    /// The address of the piece.
    private(set) var address: Address?
    
    /// The state of the piece.
    var state: State
    {
        didSet
        {
            switch state
            {
            case .standard:
                colorFilter.isHidden = true
            case .success:
                colorFilter.backgroundColor =  UIColor(displayP3Red: 0, green: 1, blue: 0, alpha: 0.3)
                colorFilter.isHidden = false
            case .failure:
                colorFilter.backgroundColor =  UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.3)
                colorFilter.isHidden = false
            case .disabled:
                colorFilter.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
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
    /// Initialize a new piece view from a piece object with a direction and address.
    ///
    /// - Parameters:
    ///   - piece: The piece object.
    ///   - tileSize: The tile size.
    convenience init(_ piece: Piece, tileSize: CGFloat)
    {
        self.init(owner: piece.owner, building: piece.building, tileSize: tileSize)
        
        // Rotate to direction
        let angle = CGFloat(piece.direction.rawValue) * (CGFloat.pi / 2)
        rotate(to: angle)
        
        
        // Adjust address based on direction
        var address = piece.address
        let (width, height) = building.dimensions(direction: piece.direction)
        switch piece.direction
        {
        case .north:
            // Top-left corner (no need to change address)
            break;
        case .east:
            // Top-right corner
            address.col -= width - 1
        case .south:
            // Bottom-right corner
            address.col -= width - 1
            address.row -= height - 1
        case .west:
            // Bottom-left corner
            address.row -= height - 1
        }
        
        // Move to adjusted address
        let point = CGPoint(address, tileSize: tileSize)
        move(to: point)
        
        self.direction = piece.direction
        self.address = piece.address
    }
    
    /// Initialize a new piece view without a direction or address.
    ///
    /// - Parameters:
    ///   - owner: The owner.
    ///   - building: The building type.
    ///   - tileSize: The tile size.
    init(owner: Owner, building: Building, tileSize: CGFloat)
    {
        self.tileSize = tileSize
        
        self.owner = owner
        self.building = building
        self.state = .standard
        
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
        self.direction = nil
        self.address = nil
    }
    
    /// Rotate the piece to a new angle.
    ///
    /// - Parameter newAngle: The new angle.
    func rotate(to newAngle: CGFloat)
    {
        self.angle = newAngle
        self.direction = nil
        self.address = nil
        transform = CGAffineTransform(rotationAngle: newAngle)
    }
    
    /// Snap the piece to a point along the grid.
    ///
    /// - Returns: The snapped address of the piece.
    func snapToBoard()
    {
        // (1) Snap to the nearest half-pi
        let halfPi = CGFloat.pi / 2
        let angle = self.angle.snap(to: halfPi)
        rotate(to: angle)
        
        // Count the number of half-pis and add 4 until its positive
        var halfPis = Int8((angle / halfPi).rounded())
        while halfPis < 0
        {
            halfPis += 4
        }
        
        // Mod 4 to get the direction raw value
        let direction = Direction(rawValue: UInt8(halfPis % 4))!
        
        
        // (2) Snap to the nearest point
        var point = self.frame.origin
        point.x = point.x.snap(to: tileSize)
        point.y = point.y.snap(to: tileSize)
        var address = point.toAddress(tileSize: tileSize)
        
        
        // (3) Snap onto board
        let (width, height) = building.dimensions(direction: direction)
        // Left
        if address.col < 0
        {
            address.col = 0
        }
        
        // Top
        if address.row < 0
        {
            address.row = 0
        }
        
        // Right
        if (address.col + width) > 10
        {
            address.col = 10 - width
        }
        
        // Bottom
        if (address.row + height) > 10
        {
            address.row = 10 - height
        }
        
        // Move frame to position
        move(to: CGPoint(address, tileSize: tileSize))
        
        
        // (4) Adjust address based on direction
        switch direction
        {
        case .north:
            // Top-left corner (no need to change address)
            break;
        case .east:
            // Top-right corner
            address.col += width - 1
        case .south:
            // Bottom-right corner
            address.col += width - 1
            address.row += height - 1
        case .west:
            // Bottom-left corner
            address.row += height - 1
        }
        
        self.direction = direction
        self.address = address
    }
    
    /// Reset the tile size to a new value.
    ///
    /// - Parameter tileSize: The new tile size.
    private func resetTileSize(_ tileSize: CGFloat)
    {
        let (width, height) = building.dimensions(direction: .north)
        let size = CGSize(width: tileSize * CGFloat(width), height: tileSize * CGFloat(height))
        self.frame = CGRect(origin: self.frame.origin, size: size)
    }
    
    
    //MARK: - State Enum
    enum State: UInt8
    {
        /// Standard, unhighlighted.
        case standard
        /// Highlighted in green.
        case success
        /// Highlighted in red.
        case failure
        /// Disabled, aka darkened
        case disabled
    }
}
