//
//  ClaimedTileView.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/20/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import UIKit


/// A claimed tile view.
class ClaimedTileView: UIView
{
    //MARK: - Properties
    /// The owner of the tile.
    let owner: Owner
    
    /// The address of the tile.
    let address: Address
    
    
    //MARK: - Initialization
    /// Initialize a new claimed tile view.
    ///
    /// - Parameters:
    ///   - owner: The owner.
    ///   - address: The claimed address.
    ///   - tileSize: The initial tile size.
    init(owner: Owner, address: Address, tileSize: CGFloat)
    {
        assert(!owner.isChurch, "The church can't claim a tile")
        
        self.owner = owner
        self.address = address
        
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: tileSize, height: tileSize)))
        
        if (owner == .light)
        {
            backgroundColor = UIColor(red: 0.67, green: 0.49, blue: 0.28, alpha: 0.8)
        }
        else
        {
            backgroundColor = UIColor(red: 0.32, green: 0.20, blue: 0.11, alpha: 0.8)
        }
        
        frame.origin = CGPoint(address, tileSize: tileSize)
    }
    
    /// Unsupported decoder initilizer.
    ///
    /// - Parameter aDecoder: The decoder.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
