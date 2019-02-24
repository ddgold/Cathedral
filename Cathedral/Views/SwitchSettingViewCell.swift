//
//  SwitchSettingViewCell.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/23/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit

/// A switch setting view cell.
class SwitchSettingViewCell: UITableViewCell
{
    //MARK: - Properties
    /// The cell's label.
    private var switchLabel: UILabel
    /// The cell's switch.
    private var switchView: UISwitch
    
    /// The handler that's called when the switch changes value.
    var valueChangedHandler: ((Bool) -> Void)?
    
    
    //MARK: - Initialization
    /// Initialize a new swich setting view cell.
    ///
    /// - Parameters:
    ///   - title: Title of the setting cell.
    ///   - isOn: Whether or not the swich is on to start.
    ///   - isOn: Whether or not the swich is enabled to start. Defaults to true.
    ///   - reuseIdentifier: The cell's reuse identifier.
    init(title: String, isOn: Bool, isEnabled: Bool = true, reuseIdentifier: String)
    {
        switchLabel = UILabel(frame: CGRect())
        switchView = UISwitch(frame: CGRect())
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        // Switch Label
        self.addSubview(switchLabel)
        switchLabel.text = title
        switchLabel.translatesAutoresizingMaskIntoConstraints = false
        switchLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        switchLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        switchLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        // Switch View
        self.addSubview(switchView)
        switchView.isOn = isOn
        switchView.isEnabled = isEnabled
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        switchView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        switchView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        switchView.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        
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
    
    
    //MARK: - Button and Gesture Recognizer Actions
    /// Calls the value changed hander, if there is one.
    ///
    /// - Parameter sender: The button press sender.
    @objc func switchValueDidChange(sender: UISwitch)
    {
        if let valueChangedHandler = self.valueChangedHandler
        {
            valueChangedHandler(sender.isOn)
        }
    }
    
    
    //MARK: - Functions
    /// Updates the view to the current theme.
    ///
    /// - Parameters:
    ///     - notification: Unused.
    @objc func updateTheme(_: Notification?)
    {
        let theme = Theme.current
        
        self.switchLabel.textColor = theme.textColor
        self.switchView.onTintColor = theme.tintColor
        
        self.backgroundColor = theme.backgroundColor
    }
}
