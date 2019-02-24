//
//  MainMenuViewController.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/22/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit

/// A main menu controller.
class MainMenuViewController: UIViewController
{
    //MARK: - Properties
    /// Stack view containing main menu buttons.
    private var stackView: UIStackView!
    
    /// Continue game main menu button.
    private var continueGameButton: UIButton!
    /// New game main menu button.
    private var newGameButton: UIButton!
    /// Settings main menu button.
    private var settingsButton: UIButton!
    
    
    /// The currently paused game that could be continued.
    private var pausedGame: Game?
    
    
    //MARK: - ViewController Lifecycle
    /// Initialze the controller's sub views once the controller has loaded.
    override func viewDidLoad()
    {
        
        testContinue()
        super.viewDidLoad()
        
        navigationItem.title  = "Cathedral"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Menu", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        view.backgroundColor = UIColor.white
        
        // Continue Game
        continueGameButton = UIButton(type: .system)
        continueGameButton.setTitle("Continue Game", for: .normal)
        continueGameButton.addTarget(self, action: #selector(continueGameButtonPressed), for: .touchUpInside)
        updateContinueGameButton()
        
        // New Game
        newGameButton = UIButton(type: .system)
        newGameButton.setTitle("New Game", for: .normal)
        newGameButton.addTarget(self, action: #selector(newGameButtonPressed), for: .touchUpInside)
        
        // Settings Game
        settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        
        // Stack View
        stackView = UIStackView(arrangedSubviews: [continueGameButton, newGameButton, settingsButton])
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Listen for theme changes
        Theme.subscribe(self, selector: #selector(updateTheme(_:)))
        updateTheme(nil)
    }
    
    
    //MARK: - Button and Gesture Recognizer Actions
    /// Continue game button has been pressed.
    ///
    /// - Parameter sender: The button press sender.
    @objc func continueGameButtonPressed(_ sender: UIButton)
    {
        presentGameViewController(pausedGame!)
    }
    
    /// New game button has been pressed.
    ///
    /// - Parameter sender: The button press sender.
    @objc func newGameButtonPressed(_ sender: UIButton)
    {
        if (pausedGame != nil)
        {
            // Alert about lost of paused game
            let alert = UIAlertController(title: "Start new game?", message: "Starting a new game will lose all progress in the game already unway.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {_ in
                self.presentGameViewController(Game())
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
            return
        }
        
        presentGameViewController(Game())
    }
    
    /// Settings button has been pressed.
    ///
    /// - Parameter sender: The button press sender.
    @objc func settingsButtonPressed(_ sender: UIButton)
    {
        let settingsViewController = SettingsViewController()
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    
    //MARK: - Functions
    /// Update the enabled status of the continueGameButton
    private func updateContinueGameButton()
    {
        continueGameButton.isEnabled = (pausedGame != nil)
    }
    
    /// Present a game view controller with the give game.
    ///
    /// - Parameter game: The game object.
    private func presentGameViewController(_ game: Game)
    {
        let gameViewController = GameViewController()
        gameViewController.game = game
        gameViewController.completionHandler = { completionGame in
            if let game = completionGame, !game.builtPieces.isEmpty
            {
                self.pausedGame = game
            }
            self.updateContinueGameButton()
        }
        
        self.pausedGame = nil
        self.updateContinueGameButton()
        
        navigationController?.pushViewController(gameViewController, animated: true)
    }
    
    /// Build a most complete game to test the continue button.
    private func testContinue()
    {
        let log = """
                  CAe66
                  SQn00
                  BRs22
                  CSw09
                  TOw05
                  SQn78
                  CSw26
                  BRe59
                  ACn54
                  IFn06
                  ABe96
                  """
        pausedGame = Game(log: log)
    }
    
    /// Updates the view to the current theme.
    ///
    /// - Parameters:
    ///     - notification: Unused.
    @objc func updateTheme(_: Notification?)
    {
        let theme = Theme.current
        
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.barStyle = theme.barStyle
        
        continueGameButton.tintColor = theme.tintColor
        newGameButton.tintColor = theme.tintColor
        settingsButton.tintColor = theme.tintColor
        
        view.backgroundColor = theme.backgroundColor
    }
}
