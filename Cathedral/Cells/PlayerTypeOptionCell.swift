//
//  PlayerTypeOptionCell.swift
//  Cathedral
//
//  Created by Doug Goldstein on 3/10/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit

/// A player type option cell.
class PlayerTypeOptionCell: UITableViewCell
{
    //MARK: - Properties
    /// The state of the cell.
    var state: State
    {
        didSet
        {
            updateState()
        }
    }
    
    
    //MARK: - Initialization
    /// Initialize a new swich setting view cell.
    ///
    /// - Parameters:
    ///   - title: Title of the setting cell.
    ///   - state: Whether or not the swich is on to start. Defaults to unselected.
    ///   - reuseIdentifier: The cell's reuse identifier.
    init(title: String, state: State = .unselected, reuseIdentifier: String)
    {
        self.state = state
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.textLabel?.text = title
        updateState()
        
        
        // Listen for theme changes
        Theme.subscribe(self, selector: #selector(updateTheme(_:)))
        updateTheme(nil)
    }
    
    /// Unsupported decoder initilizer.
    ///
    /// - Parameter aDecoder: The decoder.
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Functions
    /// Update the state of the cell.
    private func updateState()
    {
        switch self.state
        {
        case .selected:
            self.accessoryType = .checkmark
        case .unselected:
            self.accessoryType = .none
        case .disabled:
            self.accessoryType = .detailButton
        }
    }
    
    /// Updates the view to the current theme.
    ///
    /// - Parameters:
    ///     - notification: Unused.
    @objc func updateTheme(_: Notification?)
    {
        let theme = Theme.activeTheme
        
        self.textLabel?.textColor = theme.textColor
        self.tintColor = theme.tintColor
        
        self.backgroundColor = theme.foregroundColor
    }
    
    
    //MARK: - State Enum
    enum State: UInt8
    {
        /// The currently selected option.
        case selected
        /// An unselected option.
        case unselected
        /// An disabled, unavailable, option.
        case disabled
    }
}
