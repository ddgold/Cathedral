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
        assert(!owner.isChurch, "Can't populate pool for the church")
        
        pieces = [PieceView]()
        
        super.init(frame: CGRect(x: 0, y: 0, width: tileSize * 14, height: tileSize * 3 + 20))
        
        let keys = buildings.keys.sorted { (lhs, rhs) -> Bool in
            return lhs.rawValue < rhs.rawValue
        }
        
        for building in keys
        {
            addPiece(PieceView(owner: owner, building: building, tileSize: tileSize), dontRefresh: true)
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
    /// Add a piece to the pool at the end
    ///
    /// - Parameters:
    ///   - piece: The new piece.
    ///   - dontRefresh: Whether or not refeshing the pool should be skipped.  Defaults to false.
    public func addPiece(_ piece: PieceView, dontRefresh: Bool = false)
    {
        let insertAt = pieces.count
        addPiece(piece, at: insertAt, dontRefresh: dontRefresh)
    }
    
    /// Add a piece to the pool at a given the touch location.
    ///
    /// - Parameters:
    ///   - piece: The new piece.
    ///   - at: The touch location.
    ///   - dontRefresh: Whether or not refeshing the pool should be skipped.  Defaults to false.
    public func addPiece(_ piece: PieceView, at: CGPoint, dontRefresh: Bool = false)
    {
        var insertAt = pieces.count
        
        let offsetX = at.x + contentOffset.x
        var runningX: CGFloat = 10
        
        for (index, piece) in pieces.enumerated()
        {
            runningX += (piece.frame.width / 2)
            if offsetX < runningX
            {
                insertAt = index
                break;
            }
            runningX += (piece.frame.width / 2) + 10
        }
        
        
        addPiece(piece, at: insertAt, dontRefresh: dontRefresh)
    }
    
    /// Add a piece to the pool at a given index.
    ///
    /// - Parameters:
    ///   - piece: The new piece.
    ///   - at: The index.
    ///   - dontRefresh: Whether or not refeshing the pool should be skipped.  Defaults to false.
    public func addPiece(_ piece: PieceView, at: Int, dontRefresh: Bool = false)
    {
        piece.rotate(to: 0)
        piece.state = .standard
        
        self.addSubview(piece)
        pieces.insert(piece, at: at)
        
        if !dontRefresh
        {
            refresh()
        }
    }
    
    /// Select the piece from the pool given the touch location.
    ///
    /// - Parameter at: The touch location.
    /// - Returns: A tuple, where the fist element is the index, and the second element is the piece. Or, null if touch is not inside a piece.
    public func selectPiece(at: CGPoint) -> (Int, PieceView)?
    {
        for (index, piece) in pieces.enumerated()
        {
            if piece.contains(point: self.convert(at, to: piece))
            {
                return (index, piece)
            }
        }
        
        return nil
    }
    
    /// Remove the piece from the pool given a piece object.
    ///
    /// - Parameter piece: The piece object.
    public func removePiece(_ building: Building)
    {
        for (index, piece) in pieces.enumerated()
        {
            if (piece.building == building)
            {
                removePiece(at: index)
                return
            }
        }
        fatalError("Piece is not in pool")
    }
    
    /// Remove the piece from the pool at a given index.
    ///
    /// - Parameter at: The index.
    public func removePiece(at: Int)
    {
        pieces.remove(at: at).removeFromSuperview()
        refresh()
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
        
        // Set left contentInset if content narrower than frame
        if contentSize.width < frame.width
        {
            let freeSpace = frame.width - contentSize.width
            contentInset.left = freeSpace / 2
        }
        else
        {
            contentInset.left = 0
        }
    }
}
