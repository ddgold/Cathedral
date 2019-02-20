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
    /// The game model
    var game: Game!
    
    /// The game board and pool views.
    private var boardView: BoardView!
    private var topPoolView: PoolView!
    private var bottomPoolView: PoolView!
    
    /// The active piece and pool.
    private var activePiece: PieceView?
    private var activePool: PoolView?
    
    /// The point of a pan gesture's start.
    private var panStart: CGPoint?
    /// The offset of a pan gesture into the active piece.
    private var panOffset: CGPoint?
    
    
    /// The rotation of the active piece before the rotation gesture.
    private var rotateStart: CGFloat?
    
    // Pool Long Press Gesture Inital State
    private var pressedPiece: PieceView?
    private var pressStart: CGPoint?
    private var pressOffset: CGPoint?
    
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
        
        // Initialize boardView
        boardView = BoardView(tileSize: tileSize)
        view.addSubview(boardView)
        boardView.translatesAutoresizingMaskIntoConstraints = false
        boardView.heightAnchor.constraint(equalToConstant: tileSize * 12).isActive = true
        boardView.widthAnchor.constraint(equalToConstant: tileSize * 12).isActive = true
        boardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        boardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let boardPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleBoardPanGesture))
        boardView.addGestureRecognizer(boardPanRecognizer)
        let boardDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBoardDoubleTap))
        boardDoubleTapRecognizer.numberOfTapsRequired = 2
        boardView.addGestureRecognizer(boardDoubleTapRecognizer)
        let boardRotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleBoardRotation))
        boardView.addGestureRecognizer(boardRotationRecognizer)
        
        
        // Initialize topPoolView
        topPoolView = PoolView(owner: .dark, buildings: game.unbuiltBuildings(for: .dark), tileSize: tileSize)
        view.addSubview(topPoolView)
        topPoolView.translatesAutoresizingMaskIntoConstraints = false
        topPoolView.heightAnchor.constraint(equalToConstant: (tileSize * 3) + 20).isActive = true
        topPoolView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        topPoolView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        topPoolView.bottomAnchor.constraint(equalTo: boardView.topAnchor, constant: 0).isActive = true
        
        let topPoolTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePoolLongPress))
        topPoolView.addGestureRecognizer(topPoolTapRecognizer)
        
        
        // Initialize bottomPoolView
        bottomPoolView = PoolView(owner: .light, buildings: game.unbuiltBuildings(for: .light), tileSize: tileSize)
        view.addSubview(bottomPoolView)
        bottomPoolView.translatesAutoresizingMaskIntoConstraints = false
        bottomPoolView.heightAnchor.constraint(equalToConstant: (tileSize * 3) + 20).isActive = true
        bottomPoolView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        bottomPoolView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        bottomPoolView.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 0).isActive = true
        
        let bottomPoolTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePoolLongPress))
        bottomPoolView.addGestureRecognizer(bottomPoolTapRecognizer)
        
        
        // Bring board view to front
        self.view.bringSubviewToFront(boardView)
        
        
        // Set bottom active, for now
        activePool = bottomPoolView
    }
    
    
    //MARK: - Gesture Recognizer Actions
    /// Handle a pan gesture accross the game board view.
    ///
    /// - Parameter sender: The pan gesture recognizer.
    @objc func handleBoardPanGesture(_ sender: UIPanGestureRecognizer)
    {
        if let activePiece = self.activePiece
        {
            switch sender.state
            {
            // Began dragging piece
            case .began:
                if activePiece.contains(point: sender.location(in: activePiece))
                {
                    let touchLocation = sender.location(in: boardView)
                    
                    panStart = activePiece.frame.origin
                    panOffset = CGPoint(x: touchLocation.x - panStart!.x, y: touchLocation.y - panStart!.y)
                }
            
            // Dragged piece
            case .changed:
                if let panOffset = self.panOffset
                {
                    let touchLocation = sender.location(in: boardView)
                    let offsetLocation = CGPoint(x: touchLocation.x - panOffset.x, y: touchLocation.y - panOffset.y)
                    
                    activePiece.move(to: offsetLocation)
                }
            
            // Stopped dragging piece
            case .ended:
                if let panOffset = self.panOffset
                {
                    let touchLocation = sender.location(in: boardView)
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
                
            // Do nothing
            default:
                break
            }
        }
    }
    
    /// Handle a double tap gesture on the game board view.
    ///
    /// - Parameter sender: The double tap gesture recognizer.
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
    
    /// Handle a long press on one of the pool views.
    ///
    /// - Parameter sender: The long press gesture recognizer.
    @objc func handlePoolLongPress(_ sender: UILongPressGestureRecognizer)
    {
        // There's already an active piece
        if self.activePiece != nil
        {
            return
        }
        
        if let activePool = self.activePool
        {
            switch sender.state
            {
            // Began dragging piece
            case .began:
                let poolTouchLocation = sender.location(in: activePool)
                if let selectedPiece = activePool.removePiece(at: poolTouchLocation)
                {
                    let boardTouchLocation = sender.location(in: boardView)
                    
                    pressStart = activePool.convert(selectedPiece.frame, to: boardView).origin
                    pressOffset = CGPoint(x: boardTouchLocation.x - pressStart!.x, y: boardTouchLocation.y - pressStart!.y)
                    pressedPiece = selectedPiece
                    
                    boardView.addSubview(pressedPiece!)
                    
                    pressedPiece!.frame = CGRect(origin: pressStart!, size: pressedPiece!.frame.size)
                }
            
            // Dragged piece
            case .changed:
                if let pressedPiece = self.pressedPiece, let pressOffset = self.pressOffset
                {
                    let boardTouchLocation = sender.location(in: boardView)
                    let offsetLocation = CGPoint(x: boardTouchLocation.x - pressOffset.x, y: boardTouchLocation.y - pressOffset.y)
                    
                    pressedPiece.move(to: offsetLocation)
                }
            
            // Stopped dragging piece
            case .ended:
                if let pressedPiece = self.pressedPiece, let pressOffset = self.pressOffset
                {
                    let boardTouchLocation = sender.location(in: boardView)
                    let offsetLocation = CGPoint(x: boardTouchLocation.x - pressOffset.x, y: boardTouchLocation.y - pressOffset.y)
                        
                    boardView.buildPiece(pressedPiece, at: Address(0,0))
                    activePiece = pressedPiece
                    activePiece!.move(to: offsetLocation)
                    snapActivePiece()
                    
                    self.pressStart = nil
                    self.pressOffset = nil
                    self.pressedPiece = nil
                }
            
            // Cancel dragging piece
            case .cancelled:
                if let pressedPiece = self.pressedPiece, let pressStart = self.pressStart
                {
                    activePool.addPiece(pressedPiece, at: pressStart)
                    
                    self.pressStart = nil
                    self.pressOffset = nil
                    self.pressedPiece = nil
                }
                
            // Do nothing
            default:
                break
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

