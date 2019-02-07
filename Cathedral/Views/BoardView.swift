//
//  BoardView.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/30/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit


/// A game board view.
class BoardView: UIImageView
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
    
    
    //MARK: - Initialization
    /// Initilize a new board view with a given tile size.
    ///
    /// - Parameter tileSize: The tile size.
    init(tileSize: CGFloat)
    {
        self.tileSize = tileSize
        
        let imageName = "Board"
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
    /// Build a piece view on the board at a given address.
    ///
    /// - Parameters:
    ///   - piece: The piece view.
    ///   - address: The address.
    func buildPiece(_ piece: PieceView, at address: Address)
    {
        piece.frame.origin = addressToPoint(address)
        addSubview(piece)
    }
    
    /// Convert a given address ot the applicable point on the board.
    ///
    /// - Parameter address: The address.
    /// - Returns: The point equivalent to the address.
    func addressToPoint(_ address: Address) -> CGPoint
    {
        let x = CGFloat(address.col + 1) * tileSize
        let y = CGFloat(address.row + 1) * tileSize
        return CGPoint(x: x, y: y)
    }
    
    /// Convert a given point to the applicable address on the board.  Make sure the point is already snapped to the grid before calling.
    ///
    /// - Parameter point: The point.
    /// - Returns: The address equivalent to the point.
    func pointToAddress(_ point: CGPoint) -> Address
    {
        let col = Int8(point.x / tileSize) - 1
        let row = Int8(point.y / tileSize) - 1
        return Address(col, row)
    }
    
    /// Snap a given point to this board's grid.
    ///
    /// - Parameter point: The point
    /// - Returns: The point with both x and y rounded to the nearest whole tile size multiple.
    func snapToBoard(_ point: CGPoint) -> CGPoint
    {
        return CGPoint(x: snapToGrid(point.x), y: snapToGrid(point.y))
    }
    
    /// Snap a given float to this board's grid.
    ///
    /// - Parameter float: The float.
    /// - Returns: The float rounded to the nearest whole tile size multiple.
    func snapToGrid(_ float: CGFloat) -> CGFloat
    {
        let remainder = float.truncatingRemainder(dividingBy: tileSize)
        
        if remainder < -(tileSize / 2)
        {
            return float - remainder - tileSize
        }
        else if remainder > (tileSize / 2)
        {
            return float - remainder + tileSize
        }
        else
        {
            return float - remainder
        }
    }
    
    /// Reset the tile size to a new value
    ///
    /// - Parameter tileSize: The new tile size
    private func resetTileSize(_ tileSize: CGFloat)
    {
        let size = CGSize(width: tileSize * 12.0, height: tileSize * 12.0)
        self.frame = CGRect(origin: self.frame.origin, size: size)
    }
}
