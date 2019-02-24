//
//  SettingsViewController.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/23/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit

/// A settings controller.
class SettingsViewController: UITableViewController
{
    //MARK: - Properties
    /// List of settings section, and cells.
    private var sections = [(name: String?, cells: [UITableViewCell])]()
    
    
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
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.title  = "Settings"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifiers.settingViewCell)
        
        let darkModeCell = SwitchSettingViewCell(title: "Dark mode", isOn: false, reuseIdentifier: Identifiers.settingViewCell)
        darkModeCell.valueChangedHandler = { newState in
            debugPrint(newState)
            Theme.change(to: Theme(newState ? .black : .white))
        }
        
        sections.append((name: "Appearance", cells: [darkModeCell]))
        
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
        return sections.count
    }
    
    /// Determines the number of cells in a given table view section.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - section: The section.
    /// - Returns: The number of cells.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sections[section].cells.count
    }
    
    /// Gets a given cells from a table view.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - indexPath: The index path to cell.
    /// - Returns: The tabel view cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return sections[indexPath.section].cells[indexPath.row]
    }
    
    /// Determines header title for a given table view section.
    ///
    /// - Parameters:
    ///   - tableView: The table view.
    ///   - section: The section.
    /// - Returns: Tht header title.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sections[section].name
    }
    
    
    //MARK: - Functions
    /// Updates the view to the current theme.
    ///
    /// - Parameters:
    ///     - notification: Unused.
    @objc func updateTheme(_: Notification?)
    {
        let theme = Theme.current
        
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.barStyle = theme.barStyle
        
        view.backgroundColor = theme.backgroundColor
    }
    
    
    //MARK: - Name Enum
    /// Table view cell identifiers.
    private struct Identifiers
    {
        static let settingViewCell = "settingViewCell"
    }
}
