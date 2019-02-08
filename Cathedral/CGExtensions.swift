//
//  CGExtensions.swift
//  Cathedral
//
//  Created by Doug Goldstein on 2/7/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import CoreGraphics

extension CGFloat
{
    /// Snap a point number to the nearest interval.
    ///
    /// - Parameter interval: The interval size.
    /// - Returns: Number snapped to nearest interval.
    func snap(to interval: CGFloat) -> CGFloat
    {
        let remainder = self.truncatingRemainder(dividingBy: interval)
        
        if remainder < -(interval / 2)
        {
            return self - remainder - interval
        }
        else if remainder > (interval / 2)
        {
            return self - remainder + interval
        }
        else
        {
            return self - remainder
        }
    }
}

extension CGPoint
{
    /// Constructs a point from an address given the tile size.
    ///
    /// - Parameters:
    ///   - address: The address.
    ///   - tileSize: The tile size.
    init(_ address: Address, tileSize: CGFloat)
    {
        let x = CGFloat(address.col + 1) * tileSize
        let y = CGFloat(address.row + 1) * tileSize
        self.init(x: x, y: y)
    }
    
    /// Converts a point to an address given the tile size.
    ///
    /// - Parameter tileSize: The tile size.
    /// - Returns: The converted address.
    func toAddress(tileSize: CGFloat) -> Address
    {
        let col = Int8(self.x / tileSize) - 1
        let row = Int8(self.y / tileSize) - 1
        return Address(col, row)
    }
}
