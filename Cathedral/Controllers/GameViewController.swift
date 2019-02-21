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
    
    /// The static sub views of the game.
    private var boardView: BoardView!
    private var topPoolView: PoolView!
    private var bottomPoolView: PoolView!
    private var messageLabel: UILabel!
    private var buildButton: UIButton!
    
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
        
        
        // Initialize messageLabel
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 100))
        view.addSubview(messageLabel)
        messageLabel.text = "Place Holder"
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: topPoolView.topAnchor, constant: 0).isActive = true
        
        
        // Initialize buildButton
        buildButton = UIButton(type: .system)
        view.addSubview(buildButton)
        buildButton.setTitle("Build Building", for: .normal)
        buildButton.translatesAutoresizingMaskIntoConstraints = false
        buildButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buildButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        buildButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        buildButton.topAnchor.constraint(equalTo: bottomPoolView.bottomAnchor, constant: 0).isActive = true
        
        buildButton.addTarget(self, action: #selector(buildButtonPressed), for: .touchUpInside)
        
        
        // Bring board view to front and set background color
        self.view.bringSubviewToFront(boardView)
        self.view.backgroundColor = .white
        
        
        // Start / resume Game
        nextTurn()
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
                    
                    pickupActivePiece()
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
                    putdownActivePiece()
                    
                    self.panStart = nil
                    self.panOffset = nil
                }
            
            // Cancel dragging piece
            case .cancelled:
                if let panStart = self.panStart
                {
                    activePiece.move(to: panStart)
                    putdownActivePiece()
                    
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
                pickupActivePiece()
                
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
                    putdownActivePiece()
                    
                    self.rotateStart = nil
                }
                
            // Cancel Spinning Piece
            case .cancelled:
                if let rotateStart = self.rotateStart
                {
                    // Reset active piece rotation
                    activePiece.rotate(to: rotateStart)
                    putdownActivePiece()
                    
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
            if activePiece.contains(point: sender.location(in: activePiece))
            {
                activePiece.rotate(to: activePiece.angle + (CGFloat.pi / 2))
                putdownActivePiece()
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
                        
                    boardView.buildPiece(pressedPiece)
                    activePiece = pressedPiece
                    activePiece!.move(to: offsetLocation)
                    putdownActivePiece()
                    
                    self.pressStart = nil
                    self.pressOffset = nil
                    self.pressedPiece = nil
                }
            
            // Cancel dragging piece
            case .cancelled:
                if let pressedPiece = self.pressedPiece
                {
                    activePool.addPiece(pressedPiece)
                    
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
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @objc func buildButtonPressed(_ sender: UIButton)
    {
        assert(activePiece != nil, "There isn't an active Piece")
        
        // Build Piece in modal
        buildPiece(activePiece!)
        
        // Update view
        activePiece!.state = .Standard
        activePiece = nil
        
        nextTurn()
    }
    
    
    //MARK: - Functions
    /// Start moving the active piece.
    /// - Note: There must be an active piece.
    private func pickupActivePiece()
    {
        guard let activePiece = self.activePiece else
        {
            fatalError("There is no active Piece")
        }
        
        buildButton.isEnabled = false
        activePiece.state = .Standard
    }
    
    
    /// Stop moving the active piece, snapping it to the board, or putting back into the active pool.
    /// - Note: There must be an active piece.
    private func putdownActivePiece()
    {
        guard let activePiece = self.activePiece else
        {
            fatalError("There is no active piece")
        }
        
        activePiece.snapToBoard()
        
        // Update state
        if canBuildPiece(activePiece)
        {
            buildButton.isEnabled = true
            activePiece.state = .Success
        }
        else
        {
            buildButton.isEnabled = false
            activePiece.state = .Failure
        }
    }
    
    /// Determines if a given piece view can be built.
    /// - Note: If the piece's address or direction is not set, checks if the piece can be built anywhere.
    ///
    /// - Parameter piece: The piece view.
    /// - Returns: Whether the given piece can be built.
    private func canBuildPiece(_ piece: PieceView) -> Bool
    {
        if (piece.address == nil) || (piece.direction == nil)
        {
            return game!.canBuildBuilding(piece.building, for: piece.owner)
        }
        else
        {
            return game!.canBuildBuilding(piece.building, for: piece.owner, facing: piece.direction!, at: piece.address!)
        }
    }
    
    /// Build a given piece view at its current position.
    /// - Note: Piece must have address and direction set, and be in a valid position.
    ///
    /// - Parameter piece: The piece view.
    private func buildPiece(_ piece: PieceView)
    {
        assert((piece.address != nil) && (piece.direction != nil), "Must set piece's address and direciton before building it")
        assert(canBuildPiece(piece), "Piece at an invalid position")
        
        let (claimant, destroyed) = game!.buildBuilding(piece.building, for: piece.owner, facing: piece.direction!, at: piece.address!)
        
        for address in claimant
        {
            let claimedTile = ClaimedTileView(owner: piece.owner, address: address, tileSize: tileSize)
            boardView.claimTile(claimedTile)
        }
        
        for piece in destroyed
        {
            let pieceView = boardView.destroyPiece(piece)

            // If Cathedral piece, remove from superviews, else return to pool
            switch piece.owner
            {
            case .church:
                pieceView.removeFromSuperview()

            case .light:
                poolForPlayer(.light).addPiece(pieceView)

            case .dark:
                poolForPlayer(.dark).addPiece(pieceView)
            }
        }
    }
    
    /// Get the correct pool for a given player.
    ///
    /// - Parameter owner: The owner, must be a player.
    /// - Returns: The pool for the given player.
    private func poolForPlayer(_ owner: Owner) -> PoolView
    {
        assert(owner.isPlayer, "Church does not have Pool")
        
        if (owner == .dark)
        {
            return topPoolView
        }
        else
        {
            return bottomPoolView
        }
    }
    
    /// Move on to the next turn.
    private func nextTurn()
    {
        // Turn off build button
        buildButton.isEnabled = false
        
        // Update which building in pools can be built
        for case let pieceView as PieceView in (topPoolView.subviews + bottomPoolView.subviews)
        {
            if (!canBuildPiece(pieceView))
            {
                pieceView.state = .Failure
            }
        }
        
        // Set message and potential active piece (for Cathedral turn) or pool (for player turn)
        if let nextTurn = game!.nextTurn
        {
            switch nextTurn
            {
            case .church:
                messageLabel.text = "Build the Cathedral"
                activePiece = PieceView(owner: .church, building: .cathedral, tileSize: tileSize)
                boardView.buildPiece(activePiece!)
                activePool = nil
                
            case .dark:
                messageLabel.text = "It's dark's turn to build."
                activePool = poolForPlayer(.dark)
                
            case .light:
                messageLabel.text = "It's light's turn to build."
                activePool = poolForPlayer(.light)
            }
        }
        else
        {
            let (winner, _) = game!.calculateWinner()!
            
            if let winner = winner
            {
                debugPrint(winner)
                messageLabel.text = "Game is over, \(winner) is the winner!"
            }
            else
            {
                messageLabel.text = "Game is over, it was a tie."
            }
            
            game = nil
            activePool = nil
        }
    }
}

