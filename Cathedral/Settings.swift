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
    private init()
    {
        
    }
    
    /// Whether or not the cathedral placement should be delayed until after the first dark piece has been placed.
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
    
    /// Whether or not to auto-build once one player can no longer build, and there are enough tiles to build all remaining pieces.
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
}
