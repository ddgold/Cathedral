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
//        tableView.allowsSelection = false
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
        }
        
        sections.append((name: "Appearance", cells: [darkModeCell]))
    }
    
    //MARK: - UITableViewController
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sections[section].cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return sections[indexPath.section].cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return sections[section].name
    }
    
    
    
    private struct Identifiers
    {
        static let settingViewCell = "settingViewCell"
    }
}
