//
//  NewGameViewController.swift
//  Cathedral
//
//  Created by Doug Goldstein on 3/10/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit

/// <#Description#>
class NewGameViewController: UITableViewController
{
    //MARK: - Properties
    /// List of player type options fot light owner.
    var lightPlayerOptions: [PlayerTypeOptionCell]!
    /// List of player type options fot dark owner.
    var darkPlayerOptions: [PlayerTypeOptionCell]!
    
    /// The play bar button.
    var playButton: UIBarButtonItem!
    
    /// The handler that's called when the play button is pressed.
    var playHandler: (() -> Void)?
    
    
    //MARK: - Initialization
    /// Initialize a new settings controller.
    init()
    {
        super.init(style: .grouped)
    }
    
    /// Unsupported decoder initilizer.
    ///
    /// - Parameter aDecoder: The decoder.
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - ViewController Lifecycle
    /// Initialze the controller's sub views once the controller has loaded.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.title  = "New Game"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifiers.playerOptionCell)
        tableView.alwaysBounceVertical = false
        
        lightPlayerOptions = buildOptions(for: .light)
        darkPlayerOptions = buildOptions(for: .dark)
        
        playButton = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(playButtonPressed))
        self.navigationItem.rightBarButtonItem = playButton
        
        // Listen for theme changes
        Theme.subscribe(self, selector: #selector(updateTheme(_:)))
        updateTheme(nil)
    }
    
    
    //MARK: - UITableViewController
    /// Determine the number of section in table view.
    ///
    /// - Parameter tableView: The table view.
    /// - Returns: The number of sections.
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    /// Determines the number of cells in a given table view section.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - section: The section.
    /// - Returns: The number of cells.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return playerOptions(for: owner(for: section)).count
    }
    
    /// Gets a given cells from a table view.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - indexPath: The index path to cell.
    /// - Returns: The tabel view cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return playerOptions(for: owner(for: indexPath.section))[indexPath.row]
    }
    
    /// Determines header title for a given table view section.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - section: The section.
    /// - Returns: Tht header title.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        assert((section == 0) || (section == 1), "There should only be 2 sections")
        
        return (section == 0) ? "Light Player" : "Dark Player"
    }
    
    /// Handles a given cell being pressed.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - indexPath: The index path to cell.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let options = playerOptions(for: owner(for: indexPath.section))
        
        for (index,cell) in options.enumerated()
        {
            if index == indexPath.row
            {
                cell.state = .selected
            }
            else
            {
                cell.state = .unselected
            }
        }
        
    }
    
    
    //MARK: - Button and Gesture Recognizer Actions
    /// Play button has been pressed.
    ///
    /// - Parameter sender: The button press sender.
    @objc func playButtonPressed(_ sender: UIButton)
    {
        Settings.lightPlayerType = selectedOption(for: .light)
        Settings.darkPlayerType = selectedOption(for: .dark)
        
        if let playHandler = self.playHandler
        {
            playHandler()
        }
    }
    
    
    //MARK: - Functions
    /// Get the owner for a given section.
    ///
    /// - Parameter section: The section.
    /// - Returns: The player owner.
    private func owner(for section: Int) -> Owner
    {
        assert((section == 0) || (section == 1), "There should only be 2 sections")
        
        return (section == 0) ? .light : .dark
    }
    
    /// Build a default set of player options.
    ///
    /// - Parameter owner: The player owner, must be light or dark.
    /// - Returns: The defaultlist of player type options, all unselected.
    private func buildOptions(for owner: Owner) -> [PlayerTypeOptionCell]
    {
        assert(!owner.isChurch, "The church does not have pool")
        
        var options: [PlayerTypeOptionCell] = []
        let defaultType = (owner == .light) ? Settings.lightPlayerType  : Settings.darkPlayerType
        
        for type in [LocalHuman.self, RandomComputer.self] as [Player.Type]
        {
            let state: PlayerTypeOptionCell.State
            if type == defaultType
            {
                state = .selected
            }
            else
            {
                state = .unselected
            }
            
            options.append(PlayerTypeOptionCell(title: type.id, state: state, reuseIdentifier: Identifiers.playerOptionCell))
        }
        
        return options
    }
    
    /// Get the player type options for a given player owner.
    ///
    /// - Parameter owner: The player owner, must be light or dark.
    /// - Returns: A list of player type options.
    private func playerOptions(for owner: Owner) -> [PlayerTypeOptionCell]
    {
        assert(!owner.isChurch, "The church does not have pool")
        
        return (owner == .light) ? lightPlayerOptions : darkPlayerOptions
    }
    
    /// Get the currently selected player type for a given player owner.
    ///
    /// - Parameter owner: The player owner, must be light or dark.
    /// - Returns: The currently selected player type.
    private func selectedOption(for owner: Owner) -> Player.Type
    {
        let options = playerOptions(for: owner)
        for option in options
        {
            if option.state == .selected
            {
                if let id = option.textLabel?.text
                {
                    return PlayerType(id)
                }
            }
        }
        
        fatalError("No option selected")
    }
    
    /// Updates the view to the current theme.
    ///
    /// - Parameters:
    ///     - notification: Unused.
    @objc private func updateTheme(_: Notification?)
    {
        let theme = Theme.activeTheme
        
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.barStyle = theme.barStyle
        
        view.backgroundColor = theme.backgroundColor
    }
}
