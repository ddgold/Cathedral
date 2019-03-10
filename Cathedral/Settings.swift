//
//  Settings.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/24/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

/// A games settings object
struct Settings
{
    /// Initilizes a settings object, but there is no need to have an instance.
    init()
    {
        self.lightPlayerType = Settings.lightPlayerType
        self.darkPlayerType = Settings.darkPlayerType
        self.delayedCathedral = Settings.delayedCathedral
        self.autoBuild = Settings.autoBuild
    }
    
    
    //MARK: - Light Player Type
    /// The light player type.
    /// - Note: System level setting.
    static var lightPlayerType: Player.Type
    {
        get
        {
            if let playerType = UserDefaults.standard.object(forKey: "lightPlayerType") as? Player.Type
            {
                return playerType
            }
            else
            {
                return RandomComputer.self
            }
        }
        set
        {
            UserDefaults.standard.set(newValue, forKey: "lightPlayerType")
        }
    }
    /// The light player type.
    /// - Note: Game level setting.
    let lightPlayerType: Player.Type
    
    
    //MARK: - Dark Player Type
    /// The dark player type.
    /// - Note: System level setting.
    static var darkPlayerType: Player.Type
    {
        get
        {
            if let playerType = UserDefaults.standard.object(forKey: "darkPlayerType") as? Player.Type
            {
                return playerType
            }
            else
            {
                return LocalHuman.self
            }
        }
        set
        {
            UserDefaults.standard.set(newValue, forKey: "darkPlayerType")
        }
    }
    /// The dark player type.
    /// - Note: Game level setting.
    let darkPlayerType: Player.Type
    
    
    //MARK: - Delayed Cathedral
    /// Whether or not the cathedral placement should be delayed until after the first dark piece has been placed.
    /// - Note: System level setting.
    static var delayedCathedral: Bool
    {
        get
        {
            return UserDefaults.standard.bool(forKey: "delayedCathedral")
        }
        set
        {
            UserDefaults.standard.set(newValue, forKey: "delayedCathedral")
        }
    }
    /// Whether or not the cathedral placement should be delayed until after the first dark piece has been placed.
    /// - Note: Game level setting.
    let delayedCathedral: Bool
    
    
    //MARK: - Auto Build
    /// Whether or not to auto-build once one player can no longer build, and there are enough tiles to build all remaining pieces.
    /// - Note: System level setting.
    static var autoBuild: Bool
    {
        get
        {
            return UserDefaults.standard.bool(forKey: "autoBuild")
        }
        set
        {
            UserDefaults.standard.set(newValue, forKey: "autoBuild")
        }
    }
    /// Whether or not to auto-build once one player can no longer build, and there are enough tiles to build all remaining pieces.
    /// - Note: Game level setting.
    let autoBuild: Bool
}
