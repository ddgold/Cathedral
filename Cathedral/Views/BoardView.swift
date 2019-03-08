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
    /// Put a piece view on the board.
    ///
    /// - Parameters:
    ///   - piece: The piece view.
    func buildPiece(_ piece: PieceView)
    {
        addSubview(piece)
    }
    
    /// Put a tile view on the board.
    ///
    /// - Parameters:
    ///   - piece: The piece view.
    func claimTile(_ claimedTile: ClaimedTileView)
    {
        addSubview(claimedTile)
    }
    
    /// Remove a piece from the board
    ///
    /// - Parameter target: The target piece.
    /// - Returns: The removed piece view.
    func destroyPiece(_ target: Piece) -> PieceView
    {
        for case let piece as PieceView in subviews
        {
            if piece.address == target.address
            {
                return piece
            }
        }
        
        fatalError("Piece is not on board")
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
