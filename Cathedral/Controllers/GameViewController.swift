//
//  GameViewController.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit

/// A cathedral game controller.
class GameViewController: UIViewController
{
    //MARK: - Properties
    /// The game board view.
    private var boardView: BoardView!
    
    /// The active piece.
    private var activePiece: PieceView?
    
    /// The point of a pan gesture's start.
    private var panStart: CGPoint?
    /// The offset of a pan gesture into the active piece.
    private var panOffset: CGPoint?
    
    
    /// The rotation of the active piece before the rotation gesture.
    private var rotateStart: CGFloat?
    
    /// The calculate size of a tile based on controller's safe space.
    var tileSize: CGFloat
    {
        let totalSafeHeight = view.frame.height - 40
        let maxHeightSize = (totalSafeHeight - 40) / 18
        
        let totalSafeWidth = view.frame.width
        let maxWidthSize = totalSafeWidth / 12
        
        return min(maxHeightSize, maxWidthSize)
    }
    
    
    //MARK: - View Did Load
    /// Initialze the controller's sub views once the controller has loaded.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let center = CGPoint(x: view.frame.size.width  / 2, y: view.frame.size.height / 2)
        
        // Initialize boardView
        boardView = BoardView(tileSize: tileSize)
        view.addSubview(boardView)
        boardView.center = center
        let boardPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleBoardPanGesture))
        boardView.addGestureRecognizer(boardPanRecognizer)
        let boardDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBoardDoubleTap))
        boardDoubleTapRecognizer.numberOfTapsRequired = 2
        boardView.addGestureRecognizer(boardDoubleTapRecognizer)
        let boardRotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleBoardRotation))
        boardView.addGestureRecognizer(boardRotationRecognizer)
        
        
        // Add cathedral as active piece for testing
        activePiece = PieceView(owner: .church, building: .cathedral, tileSize: tileSize)
        boardView.buildPiece(activePiece!, at: Address(0, 0))
    }
    
    
    //MARK: - Gesture Recognizer Actions
    /// Handle a pan gesture accross the game board view.
    ///
    /// - Parameter sender: The pan gesture recognizer.
    @objc func handleBoardPanGesture(_ sender: UIPanGestureRecognizer)
    {
        if let activePiece = self.activePiece
        {
            let touchLocation = sender.location(in: boardView)
            
            switch sender.state
            {
            // Began dragging piece
            case .began:
                if activePiece.contains(point: sender.location(in: activePiece))
                {
                    panStart = activePiece.frame.origin
                    panOffset = CGPoint(x: touchLocation.x - panStart!.x, y: touchLocation.y - panStart!.y)
                }
                
            // Dragged piece
            case .changed:
                if let panOffset = self.panOffset
                {
                    let offsetLocation = CGPoint(x: touchLocation.x - panOffset.x, y: touchLocation.y - panOffset.y)
                    activePiece.move(to: offsetLocation)
                }
                
            // Stopped dragging piece
            case .ended:
                if let panOffset = self.panOffset
                {
                    let offsetLocation = CGPoint(x: touchLocation.x - panOffset.x, y: touchLocation.y - panOffset.y)
                    activePiece.move(to: offsetLocation)
                    snapActivePiece()
                    
                    self.panStart = nil
                    self.panOffset = nil
                }
            
            // Cancel dragging piece
            case .cancelled:
                if let panStart = self.panStart
                {
                    activePiece.move(to: panStart)
                    snapActivePiece()
                    
                    self.panStart = nil
                    self.panOffset = nil
                }
                
            // Other unapplicable states
            default:
                break
            }
        }
    }
    
    /// Handle a rotation gesture on the game board view.
    ///
    /// - Parameter sender: The rotation gesture recognizer.
    @objc func handleBoardRotation(_ sender: UIRotationGestureRecognizer)
    {
        if let activePiece = self.activePiece
        {
            switch sender.state
            {
            // Begin Spinning Piece
            case .began:
                // Record starting angle
                self.rotateStart = activePiece.angle
                
            // Spin Piece
            case .changed:
                if let rotateStart = self.rotateStart
                {
                    // Spin active piece
                    activePiece.rotate(to: rotateStart + sender.rotation)
                }
                
            // End Spinning Piece
            case .ended:
                if let rotateStart = self.rotateStart
                {
                    // Set active piece direction then snap to 90º angle and board grid
                    activePiece.rotate(to: rotateStart + sender.rotation)
                    snapActivePiece()
                    
                    self.rotateStart = nil
                }
                
            // Cancel Spinning Piece
            case .cancelled:
                if let rotateStart = self.rotateStart
                {
                    // Reset active piece rotation
                    activePiece.rotate(to: rotateStart)
                    snapActivePiece()
                    
                    self.rotateStart = nil
                }
                
            default:
                // Do nothing
                break
            }
        }
    }
    
    /// Handle a double tap gesture on the game board view.
    ///
    /// - Parameter sender: The dougle tap gesture recognizer.
    @objc func handleBoardDoubleTap(_ sender: UITapGestureRecognizer)
    {
        if let activePiece = self.activePiece
        {
            let touchLocation = sender.location(in: activePiece)
            if activePiece.contains(point: touchLocation)
            {
                activePiece.rotate(to: activePiece.angle + (CGFloat.pi / 2))
                snapActivePiece()
            }
        }
    }
    
    
    //MARK: - Functions
    /// Snap the active piece onto the board's grid.  There must be an active piece.
    private func snapActivePiece()
    {
        guard let activePiece = self.activePiece else
        {
            fatalError("There is no active piece")
        }
        
        // Snap to a direction, then calculate tile width and height of the piece
        let width: Int8
        let height: Int8
        let direction = activePiece.snapToDirection()
        if (direction == .north) || (direction == .south)
        {
            width = Int8(activePiece.building.width)
            height = Int8(activePiece.building.height)
        }
        else
        {
            width = Int8(activePiece.building.height)
            height = Int8(activePiece.building.width)
        }
        
        // Snap to grid in general, then onto the board
        var address = activePiece.snapToGrid()
        
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
        
        activePiece.move(to: CGPoint(address, tileSize: tileSize))
    }
}

