//
//  Theme.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/23/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit


/// Theme object.
struct Theme: Equatable
{
    //MARK: - Properties
    /// Current active theme.
    private(set) static var current: Theme = Theme(.white)
    
    /// Color for the tints.
    let tintColor: UIColor
    /// Style for all bars, navigator and tab.
    let barStyle: UIBarStyle
    /// Color for the background.
    let backgroundColor: UIColor
    /// Color for the text.
    let textColor: UIColor
    
    
    //MARK: - Initialization
    /// Initializes a new theme object.
    ///
    /// - Parameter name: The theme's name.
    init(_ name: Name)
    {
        switch name
        {
        case .black:
            tintColor = .orange
            barStyle = .black
            backgroundColor = UIColor(white: 0.1, alpha: 1)
            textColor = .white
            
        case .white:
            tintColor = .blue
            barStyle = .default
            backgroundColor = .white
            textColor = .black
        }
    }
    
    
    //MARK: - Functions
    /// Changes the current theme, and sends notification to all subscribers if the style has changed.
    ///
    /// - Parameter style: The theme style to change to
    static func change(to theme: Theme)
    {
        if current != theme
        {
            current = theme
            NotificationCenter.default.post(name: .themeChange, object: nil)
        }
    }
    
    /// Subscribes an object to theme changes.
    ///
    /// - Parameters:
    ///     - subscriber: Object subcribing to theme changes.
    ///     - selector: Method to call when themes change. The method specified by selectot must have one and only one argument (an instance of NSNotification).
    static func subscribe(_ subscriber: Any, selector: Selector)
    {
        NotificationCenter.default.addObserver(subscriber, selector: selector, name: .themeChange, object: nil)
    }
    
    
    //MARK: - Name Enum
    /// A theme name.
    enum Name: String
    {
        /// Darkest black theme.
        case black = "Black"
        /// Lightest white theme.
        case white = "White"
    }
}


//MARK: - Notification.Name Extention
/// Extention of Notification.Name to add themeChange.
extension Notification.Name
{
    static let themeChange = Notification.Name("com.ddgold.Cathedral.notifications.themeChange")
}
