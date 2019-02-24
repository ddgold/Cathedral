//
//  GameViewController.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    /// The active piece.
    private var activePiece: PieceView?
    /// The actice poo.
    private var activePool: PoolView?
    
    /// The point of a pan gesture's start.
    private var panStart: CGPoint?
    /// The offset of a pan gesture into the active piece.
    private var panOffset: CGPoint?
    
    
    /// The rotation of the active piece before the rotation gesture.
    private var rotateStart: CGFloat?
    
    /// The piece that the long press gestures is touching.
    private var pressedPiece: PieceView?
    /// The point of a long press gesture's start.
    private var pressStart: CGPoint?
    /// The offset of a long press gesture into the pressed piece.
    private var pressOffset: CGPoint?
    
    /// The player assigned to the top pool.
    private let topPoolPlayer = Owner.dark
    
    /// The completion handler that return the game to calling controller when this controller disappears.
    var completionHandler: ((Game?) -> Void)?
    
    /// The calculate size of a tile based on controller's safe space.
    var tileSize: CGFloat
    {
        let totalSafeHeight = view.frame.height - 40
        let maxHeightSize = (totalSafeHeight - 40) / 18
        
        let totalSafeWidth = view.frame.width
        let maxWidthSize = totalSafeWidth / 12
        
        return min(maxHeightSize, maxWidthSize)
    }
    
    
    //MARK: - ViewController Lifecycle
    /// Initialze the controller's sub views once the controller has loaded.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.title  = "Cathedral"
        
        // Initialize subviews
        boardView = buildBoard()
        topPoolView = buildPool(top: true)
        bottomPoolView = buildPool(top: false)
        messageLabel = buildMessageLabel()
        buildButton = buildBuildButton()
        
        
        // Bring board view to front and set background color
        self.view.bringSubviewToFront(boardView)
        self.view.backgroundColor = .white
        
        // Listen for theme changes
        Theme.subscribe(self, selector: #selector(updateTheme(_:)))
        updateTheme(nil)
        
        // Start / resume Game
        nextTurn()
    }
    
    /// This game controller is disappearing, return the game via the completion handler.
    ///
    /// - Parameter animated: Whether or not the disappearing is animated.
    override func viewWillDisappear(_ animated: Bool)
    {
        completionHandler?(game)
    }
    
    
    //MARK: - Button and Gesture Recognizer Actions
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
                    let boardTouchLocation = sender.location(in: boardView)
                    let offsetLocation = CGPoint(x: boardTouchLocation.x - panOffset.x, y: boardTouchLocation.y - panOffset.y)
                    
                    activePiece.move(to: offsetLocation)
                }
            
            // Stopped dragging piece
            case .ended:
                if let panOffset = self.panOffset
                {
                    let boardTouchLocation = sender.location(in: boardView)
                    let offsetLocation = CGPoint(x: boardTouchLocation.x - panOffset.x, y: boardTouchLocation.y - panOffset.y)
                    
                    if let activePool = self.activePool
                    {
                        if (activePool == topPoolView) && (boardTouchLocation.y < 0) ||
                            (activePool == bottomPoolView) && (boardTouchLocation.y > boardView.frame.height)
                        {
                            activePool.addPiece(activePiece, at: boardTouchLocation)
                            self.activePiece = nil
                            
                            self.panStart = nil
                            self.panOffset = nil
                            
                            return
                        }
                    }
                    
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
                let start = activePiece.frame.origin
                activePiece.rotate(to: activePiece.angle + (CGFloat.pi / 2))
                activePiece.move(to: start)
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
                if let (index, selectedPiece) = activePool.selectPiece(at: poolTouchLocation)
                {
                    let boardTouchLocation = sender.location(in: boardView)
                    
                    if (!canBuildPiece(selectedPiece))
                    {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    }
                    else
                    {
                        pressStart = activePool.convert(selectedPiece.frame, to: boardView).origin
                        pressOffset = CGPoint(x: boardTouchLocation.x - pressStart!.x, y: boardTouchLocation.y - pressStart!.y)
                        pressedPiece = selectedPiece
                        
                        activePool.removePiece(at: index)
                        boardView.addSubview(pressedPiece!)
                        
                        pressedPiece!.frame = CGRect(origin: pressStart!, size: pressedPiece!.frame.size)
                    }
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
                    
                    if (activePool == topPoolView) && (boardTouchLocation.y < 0) ||
                        (activePool == bottomPoolView) && (boardTouchLocation.y > boardView.frame.height)
                    {
                        activePool.addPiece(pressedPiece, at: boardTouchLocation)
                        
                        self.pressStart = nil
                        self.pressOffset = nil
                        self.pressedPiece = nil
                        
                        return
                    }
                    
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
    
    /// Handle the buildButton being pressed.
    ///
    /// - Parameter sender: The button press sender.
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
    /// Builds a new board.
    ///
    /// - Returns: The new board.
    private func buildBoard() -> BoardView
    {
        let newBoard = BoardView(tileSize: tileSize)
        
        view.addSubview(newBoard)
        newBoard.translatesAutoresizingMaskIntoConstraints = false
        newBoard.heightAnchor.constraint(equalToConstant: tileSize * 12).isActive = true
        newBoard.widthAnchor.constraint(equalToConstant: tileSize * 12).isActive = true
        newBoard.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newBoard.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
        
        let boardPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleBoardPanGesture))
        newBoard.addGestureRecognizer(boardPanRecognizer)
        let boardDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBoardDoubleTap))
        boardDoubleTapRecognizer.numberOfTapsRequired = 2
        newBoard.addGestureRecognizer(boardDoubleTapRecognizer)
        let boardRotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleBoardRotation))
        newBoard.addGestureRecognizer(boardRotationRecognizer)
        
        
        // Build existing pieces
        for piece in game.builtPieces
        {
            let pieceView = PieceView(piece, tileSize: tileSize)
            newBoard.buildPiece(pieceView)
        }
        
        // Build claimed tiles
        for claimedAddress in game.lightClaimedAddresses
        {
            let claimedTile = ClaimedTileView(owner: .light, address: claimedAddress, tileSize: tileSize)
            newBoard.claimTile(claimedTile)
        }
        
        for claimedAddress in game.darkClaimedAddresses
        {
            let claimedTile = ClaimedTileView(owner: .dark, address: claimedAddress, tileSize: tileSize)
            newBoard.claimTile(claimedTile)
        }
        
        return newBoard
    }
    
    /// Builds a new pool.
    ///
    /// - Parameter top: Whether to build a top pool or a bottom pool.
    /// - Returns: The new pool.
    private func buildPool(top: Bool) -> PoolView
    {
        let owner = top ? topPoolPlayer : topPoolPlayer.opponent
        
        let newPool = PoolView(owner: owner, buildings: game.unbuiltBuildings(for: owner), tileSize: tileSize)
        view.addSubview(newPool)
        newPool.translatesAutoresizingMaskIntoConstraints = false
        newPool.heightAnchor.constraint(equalToConstant: (tileSize * 3) + 20).isActive = true
        newPool.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        newPool.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        if top
        {
            newPool.bottomAnchor.constraint(equalTo: boardView.topAnchor, constant: 0).isActive = true
        }
        else
        {
            newPool.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 0).isActive = true
        }
        
        let poolTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePoolLongPress))
        newPool.addGestureRecognizer(poolTapRecognizer)
        
        return newPool
    }
    
    /// Builds a new messageLabel.
    ///
    /// - Returns: The new label.
    private func buildMessageLabel() -> UILabel
    {
        let newLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 100))
        view.addSubview(newLabel)
        newLabel.text = "Place Holder"
        newLabel.textAlignment = .center
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        newLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        newLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        newLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        newLabel.bottomAnchor.constraint(equalTo: topPoolView.topAnchor, constant: 0).isActive = true
        
        return newLabel
    }
    
    /// Builds a new buildButton.
    ///
    /// - Returns: The new button.
    private func buildBuildButton() -> UIButton
    {
        let newButton = UIButton(type: .system)
        view.addSubview(newButton)
        newButton.setTitle("Build Building", for: .normal)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        newButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        newButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        newButton.topAnchor.constraint(equalTo: bottomPoolView.bottomAnchor, constant: 0).isActive = true
        
        newButton.addTarget(self, action: #selector(buildButtonPressed), for: .touchUpInside)
        
        return newButton
    }
    
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

            default:
                poolForPlayer(piece.owner).addPiece(pieceView)
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
        
        if (owner == topPoolPlayer)
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
                activePiece!.move(to: CGPoint(x: tileSize * 4, y: tileSize * 4))
                putdownActivePiece()
                boardView.buildPiece(activePiece!)
                
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
    
    /// Updates the view to the current theme.
    ///
    /// - Parameters:
    ///     - notification: Unused.
    @objc func updateTheme(_: Notification?)
    {
        let theme = Theme.current
        
        messageLabel.textColor = theme.textColor
        buildButton.tintColor = theme.tintColor
        
        view.backgroundColor = theme.backgroundColor
    }
}

