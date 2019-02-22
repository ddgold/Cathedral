//
//  PoolView.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/17/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit


/// A pool of pieces view.
class PoolView: UIScrollView
{
    //MARK: - Properties
    /// List of pieces in the pool.
    private var pieces: [PieceView]
    
    //MARK: - Initialization
    /// Initialize a new piece view.
    ///
    /// - Parameters:
    ///   - owner: The owner.
    ///   - buildings: The list of pieces in the pool.
    ///   - tileSize: The initial tile size.
    init(owner: Owner, buildings: Dictionary<Building, Bool>, tileSize: CGFloat)
    {
        assert(owner.isPlayer, "Can't populate Pool for Church")
        
        pieces = [PieceView]()
        
        super.init(frame: CGRect(x: 0, y: 0, width: tileSize * 14, height: tileSize * 3 + 20))
        
        let keys = buildings.keys.sorted { (lhs, rhs) -> Bool in
            return lhs.rawValue < rhs.rawValue
        }
        
        for building in keys
        {
            addPiece(PieceView(owner: owner, building: building, tileSize: tileSize))
        }
        
        refresh()
    }
    
    /// Unsupported decoder initilizer.
    ///
    /// - Parameter aDecoder: The decoder.
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Functions
    /// Add a piece to the pool given the touch location.
    ///
    /// - Parameters:
    ///   - piece: The new piece.
    public func addPiece(_ piece: PieceView)
    {
        addPiecePrivate(piece)
        refresh()
    }
    
    /// Remove a piece from the pool given the touch location.
    ///
    /// - Parameter at: The touch location.
    /// - Returns: The piece, removed from the pool, at the location, if there is one.
    public func removePiece(at: CGPoint) -> PieceView?
    {
        for (index, piece) in pieces.enumerated()
        {
            if piece.contains(point: self.convert(at, to: piece))
            {
                pieces.remove(at: index)
                piece.removeFromSuperview()
                
                refresh()
                return piece
            }
        }
        
        return nil
    }
    
    /// Add a piece to the pool. Private portion that doesn't include a call to refresh.
    ///
    /// - Parameter piece: The new piece.
    private func addPiecePrivate(_ piece: PieceView)
    {
        self.addSubview(piece)
        pieces.append(piece)
    }
    
    /// Refresh the location of the pieces in the pool.
    private func refresh()
    {
        var totalWidth: CGFloat = 10
        let totalHeight = self.frame.height
        
        for piece in pieces
        {
            let pieceHeight = piece.frame.height
            piece.frame.origin = CGPoint(x: totalWidth, y: (totalHeight - pieceHeight) / 2)
            
            totalWidth += piece.frame.width + 10
        }
        
        self.contentSize = CGSize(width: totalWidth, height: totalHeight)
    }
}
