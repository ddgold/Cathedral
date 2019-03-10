//
//  Game.swift
//  Cathedral
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import Foundation

/// A game of cathedral.
class Game: NSObject, NSCoding
{
    //MARK: - Properties
    /// The setting used for this game.
    private let settings: Settings
    /// The game board.
    private(set) var board: Board
    /// The set of light's unbuilt buildings.
    private var lightUnbuiltBuildings: Set<Building>
    /// The set of dark's unbuilt buildings.
    private var darkUnbuiltBuildings: Set<Building>
    /// THe set of currently built pieces.
    private(set) var builtPieces: Set<Piece>
    /// The list of built pieces, in order from first to last built.
    private(set) var buildHistory: [Piece]
    /// Whether or not the cathedral has been built.
    private(set) var cathedralBuilt: Bool
    /// The set of light's claimed address.
    private(set) var lightClaimedAddresses: Set<Address>
    /// The set of dark's claimed address.
    private(set) var darkClaimedAddresses: Set<Address>
    /// The owner who's turn is next. If nil, game is over.
    private(set) var nextTurn: Owner?
    /// The history log for this game.
    var log: String
    {
        var string = ""
        for piece in buildHistory
        {
            if string.count == 0
            {
                string += piece.log
            }
            else
            {
                string += "\n" + piece.log
            }
        }
        return string
    }
    
    //MARK: - Initialization
    /// Initializes a new game.
    override init()
    {
        board = Board()
        settings = Settings()
        
        lightUnbuiltBuildings = Building.playerBuildings
        darkUnbuiltBuildings = Building.playerBuildings
        builtPieces = []
        buildHistory = []
        cathedralBuilt = false
        lightClaimedAddresses = []
        darkClaimedAddresses = []
        
        if settings.delayedCathedral
        {
            nextTurn = .dark
        }
        else
        {
            nextTurn = .church
        }
    }
    
    /// Initializes a game from a histroy log.
    ///
    /// - Parameter log: The log entry.
    convenience init?(log: String)
    {
        self.init()
        
        let turns = log.components(separatedBy: "\n")
        for turn in turns
        {
            let owner = nextTurn!
            let building = Building(String(turn.prefix(2)))!
            let address = Address(String(turn.suffix(2)))!
            let direction = Direction(String(turn[turn.prefix(2).endIndex..<turn.suffix(2).startIndex]))!
            
            _ = buildBuilding(building, for: owner, facing: direction, at: address)
        }
    }
    
    
    //MARK: - Functions
    /// Calculates who won the game.
    ///
    /// - Returns: A tuple, where the first element is the owner, light or dark, if they won, or nil if game is a tie, and the second element is the winner's score.  Or nil, if no winner has been decided yet.
    func calculateWinner() -> (owner: Owner?, score: UInt8)?
    {
        if canMakeMove(.dark) || canMakeMove(.light)
        {
            return nil
        }
        
        let lightScore = playerScore(.light)
        let darkScore = playerScore(.dark)
        
        if (lightScore < darkScore)
        {
            return (.light, darkScore)
        }
        else if (lightScore > darkScore)
        {
            return (.dark, lightScore)
        }
        else
        {
            return (nil, 0)
        }
    }
    
    /// Get the player type for a given owner.
    ///
    /// - Parameter owner: The owner.
    /// - Returns: The player type.
    func playerType(for owner: Owner) -> Player.Type
    {
        assert(!owner.isChurch, "The church doesn't have a player type")
        
        if (owner == .light)
        {
            return settings.lightPlayerType
        }
        else
        {
            return settings.darkPlayerType
        }
    }
    
    /// Gets a dictionary where the keys are buildings the player has yet to build, and the values are whether or not the player can still possible build the building.
    ///
    /// - Parameter owner: The player owner, must be light or dark.
    /// - Returns: The dictionary of unbuilt buildings.
    func unbuiltBuildings(for owner: Owner) -> Dictionary<Building, Bool>
    {
        assert(!owner.isChurch, "The church doesn't have unbuilt buildings")
        
        var pieces = Dictionary<Building, Bool>()
        
        for building in ((owner == .light) ? lightUnbuiltBuildings : darkUnbuiltBuildings)
        {
            pieces[building] = canBuildBuilding(building, for: owner)
        }
        
        return pieces
        
    }
    
    /// Determines if a player owner can make any valid moves.
    ///
    /// - Parameter owner: The player owner, must be light or dark.
    /// - Returns: Whether or not the owner can make a move.
    func canMakeMove(_ owner: Owner) -> Bool
    {
        assert(!owner.isChurch, "The church can't make moves")
        
        for (building, canBuild) in unbuiltBuildings(for: owner)
        {
            if canBuild && canBuildBuilding(building, for: owner)
            {
                return true
            }
        }
        return false
    }
    
    /// Determines if an owner can build a specified building type anywhere on the board.
    ///
    /// - Parameters:
    ///   - building: The building type.
    ///   - owner: The owner.
    /// - Returns: Whether or not the owner can build the building type.
    func canBuildBuilding(_ building: Building, for owner: Owner) -> Bool
    {
        for row in 0..<10
        {
            for col in 0..<10
            {
                let targetAddress = Address(Int8(col), Int8(row))
                for direction in Direction.cardinalDirections
                {
                    if (canBuildBuilding(building, for: owner, facing: direction, at: targetAddress))
                    {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    /// Determines if an owner can build a specified building type at a specified direction and address.
    ///
    /// - Parameters:
    ///   - building: The building type.
    ///   - owner: The owner.
    ///   - direction: The direction.
    ///   - address: The address.
    /// - Returns: Whether or not the owner can build the building type.
    func canBuildBuilding(_ building: Building, for owner: Owner, facing direction: Direction, at address : Address) -> Bool
    {
        // Check if the Piece has been built
        switch owner
        {
        case .church:
            if (cathedralBuilt)
            {
                return false
            }
        case .light:
            if (!lightUnbuiltBuildings.contains(building))
            {
                return false
            }
        case .dark:
            if (!darkUnbuiltBuildings.contains(building))
            {
                return false
            }
        }
        
        // Go through blueprint and confirm tiles can be built on
        for blueprint in building.blueprint(owner: owner, facing: direction, at: address)
        {
            // Can't build if not on Board
            if (!onBoard(blueprint))
            {
                return false
            }
            
            let tile = board[blueprint]
            if let tileOwner = tile.owner
            {
                // Can't build if Piece and Tile aren't owned by the same Owner
                if (owner != tileOwner)
                {
                    return false
                }
                else
                {
                    // Even if same Owner, can onlt build on free claimed land
                    if (tile.isBuilt)
                    {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    /// Builds a specified building type at a specified direction and address, and finds any claimed addresses and pieces.
    ///
    /// - Parameters:
    ///   - building: The building type.
    ///   - building: The building type.
    ///   - direction: The direction.
    ///   - address: The address.
    /// - Returns: Tuple where the first element is a set of claimed addresses, and the second element is the set of claimed pieces.
    func buildBuilding(_ building: Building, for owner: Owner, facing direction: Direction, at address: Address) -> (Set<Address>, Set<Piece>)
    {
        assert(nextTurn == owner, "Not \(owner)'s turn to build piece")
        assert(canBuildBuilding(building, for: owner, facing: direction, at: address), "Can't build \(owner) \(building) facing \(direction) at \(address)")
        
        var totalClaimed = Set<Address>()
        var totalDestroyed = Set<Piece>()
        
        let builtPiece = Piece(owner: owner, building: building, direction: direction, address: address)
        builtPieces.insert(builtPiece)
        buildHistory.append(builtPiece)
        
        // Remove tiles from claimed sets
        for address in builtPiece.addresses()
        {
            board[address].piece = builtPiece
            
            switch owner
            {
            case .church:
                break
            case .light:
                lightClaimedAddresses.remove(address)
            case .dark:
                darkClaimedAddresses.remove(address)
            }
        }
        
        if (owner == .church)
        {
            // Set cathedral built and next turn
            cathedralBuilt = true
            nextTurn = .dark
        }
        else
        {
            // Remove builing from unbuilt set
            _ = (owner == .light) ? lightUnbuiltBuildings.remove(building) : darkUnbuiltBuildings.remove(building)
            
            // Find claims if after the player's first turns
            if (buildHistory.count > 3)
            {
                for address in builtPiece.addresses()
                {
                    for neighbor in address.neighbors()
                    {
                        if (!onBoard(neighbor))
                        {
                            continue
                        }
                        
                        let (claimed, destroyed) = claimClaimant(owner: owner, at: neighbor)
                        totalClaimed = totalClaimed.union(claimed)
                        if let destroyed = destroyed
                        {
                            totalDestroyed.insert(destroyed)
                        }
                        
                    }
                }
            }
            
            let opponent = owner.opponent
            // Check if delayed cathedral time
            if settings.delayedCathedral && (buildHistory.count == 2)
            {
                nextTurn = .church
            }
            // Set next turn to opponent if they can make move
            else if (canMakeMove(opponent))
            {
                nextTurn = opponent
            }
            // Else this player if they can move
            else if (canMakeMove(owner))
            {
                nextTurn = owner
            }
            // Else game over
            else
            {
                nextTurn = nil
            }
        }
        
        return (totalClaimed, totalDestroyed)
    }
    
    /// Claim all possible titles, including destroying upto one piece, for a player owner at a specified address.
    ///
    /// - Parameters:
    ///   - owner: The player owner, must be light or dark.
    ///   - address: The address.
    /// - Returns: Tuple where the first element is a set of claimed addresses, and the second element is a claimed pieces, if there is one.
    private func claimClaimant(owner: Owner, at address: Address) -> (Set<Address>, Piece?)
    {
        var claimed = Set<Address>()
        var destroyed: Piece?
        
        if !findClaimant(owner: owner, at: address, with: &claimed, and: &destroyed)
        {
            return ([], nil)
        }
        else
        {
            // Destroy first so claiming is valid
            if let foo = destroyed
            {
                destroyPiece(foo)
            }
            
            for claimed in claimed
            {
                claim(owner: owner, at: claimed)
            }
        }
        
        return (claimed, destroyed)
    }
    
    /// Find the addresses, and possibly piece, that make up a claiment for a player owner at a specified address.
    ///
    /// - Parameters:
    ///   - owner: The player owner, must be light or dark.
    ///   - address: The address.
    ///   - currentClaim: The set of current addresses inside the claiment.
    ///   - currentDestroy: The current piece inside the claiment.
    /// - Returns: Whether the owner has a valid claimant at the address.
    private func findClaimant(owner: Owner, at address: Address, with currentClaim: inout Set<Address>, and currentDestroy: inout Piece?) -> Bool
    {
        // Can claim target?
        if canClaim(owner: owner, at: address, with: &currentDestroy)
        {
            currentClaim.insert(address)
        }
        else
        {
            return false
        }
        
        // Check each neighbor
        for neighborAddress in address.neighbors()
        {
            // Neighbor is already in currentClaim, check next
            if currentClaim.contains(neighborAddress)
            {
                continue
            }
            
            // Neighbor is off board, check next
            if !onBoard(neighborAddress)
            {
                continue
            }
            
            // Neighbor is this owner's piece, check next
            let neighborTile = board[neighborAddress]
            if (neighborTile.owner == owner) && (neighborTile.isBuilt)
            {
                continue
            }
            
            // Else, try to expand claimant
            if findClaimant(owner: owner, at: neighborAddress, with: &currentClaim, and: &currentDestroy)
            {
                continue
            }
            
            return false
        }
        
        return true
    }
    
    /// Determines if a player owner can claim an address.
    ///
    /// - Parameters:
    ///   - owner: The player owner, must be light or dark.
    ///   - address: The address.
    ///   - currentDestroy: The current piece inside the claiment.
    /// - Returns: Whether or not the owner can claim the address.
    private func canClaim(owner: Owner, at address: Address, with currentDestroy: inout Piece?) -> Bool
    {
        assert(!owner.isChurch, "The church can't claim a tile")
        
        let tile = board[address]
        
        // Free tile
        if (tile.owner == nil) && (!tile.isBuilt)
        {
            return true
        }
        
        // Check current destroy
        if let piece = currentDestroy
        {
            return (tile.piece == piece)
        }
            // No current claim
        else
        {
            if (tile.owner == owner) || (!tile.isBuilt)
            {
                return false
            }
            else
            {
                currentDestroy = tile.piece
                return true
            }
        }
    }
    
    /// Claims an address for a player owner.
    ///
    /// - Parameters:
    ///   - owner: The player owner, must be light or dark.
    ///   - address: The address.
    private func claim(owner: Owner, at address: Address)
    {
        assert(!owner.isChurch, "The church can't claim a tile")
        assert(board[address].owner == nil, "Can only claim unclaimed tiles")
        
        board[address] = Tile(owner: owner, piece: nil)
        if (owner == .light)
        {
            lightClaimedAddresses.insert(address)
        }
        else
        {
            darkClaimedAddresses.insert(address)
        }
    }
    
    /// Removes a piece from the game board.
    ///
    /// - Parameter piece: The piece.
    private func destroyPiece(_ piece: Piece)
    {
        for address in piece.addresses()
        {
            board[address].piece = nil
            board[address].owner = nil
        }
        
        switch piece.owner
        {
        case .church:
            break
        case .light:
            lightUnbuiltBuildings.insert(piece.building)
        case .dark:
            darkUnbuiltBuildings.insert(piece.building)
        }
        
        builtPieces.remove(piece)
    }
    
    /// Determines if an address is on this board.
    ///
    /// - Parameter address: The address.
    /// - Returns: Whether or not the address is on this board.
    private func onBoard(_ address: Address) -> Bool
    {
        return (address.col > -1) && (address.col < 10) && (address.row > -1) && (address.row < 10)
    }
    
    /// Calculates a player's current score, the total size of all their remaining unbuilt buildings.
    ///
    /// - Parameter player: The player owner, must be light or dark.
    /// - Returns: The total size of remaining buildings.
    private func playerScore(_ owner: Owner) -> UInt8
    {
        assert(!owner.isChurch, "Can't calculate score for the church")
        
        var score: UInt8 = 0
        for building in (owner == .light ? lightUnbuiltBuildings : darkUnbuiltBuildings)
        {
            score += building.size
        }
        return score
    }
    
    
    //MARK: - Encoding
    private struct PropertyKey
    {
        static let settings = "settings"
        static let board = "board"
        static let lightUnbuiltBuildings = "lightUnbuiltBuildings"
        static let darkUnbuiltBuildings = "darkUnbuiltBuildings"
        static let builtPieces = "builtPieces"
        static let buildHistory = "buildHistory"
        static let cathedralBuilt = "cathedralBuilt"
        static let lightClaimedAddresses = "lightClaimedAddresses"
        static let darkClaimedAddresses = "darkClaimedAddresses"
        static let nextTurn = "nextTurn"
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(settings, forKey: PropertyKey.settings)
        aCoder.encode(board, forKey: PropertyKey.board)
        aCoder.encode(lightUnbuiltBuildings, forKey: PropertyKey.lightUnbuiltBuildings)
        aCoder.encode(darkUnbuiltBuildings, forKey: PropertyKey.darkUnbuiltBuildings)
        aCoder.encode(builtPieces, forKey: PropertyKey.builtPieces)
        aCoder.encode(buildHistory, forKey: PropertyKey.buildHistory)
        aCoder.encode(cathedralBuilt, forKey: PropertyKey.cathedralBuilt)
        aCoder.encode(lightClaimedAddresses, forKey: PropertyKey.lightClaimedAddresses)
        aCoder.encode(darkClaimedAddresses, forKey: PropertyKey.darkClaimedAddresses)
        aCoder.encode(nextTurn, forKey: PropertyKey.nextTurn)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        // Settings
        guard let settings = aDecoder.decodeObject(forKey: PropertyKey.settings) as? Settings else
        {
            return nil
        }
        self.settings = settings
        
        // Board
        guard let board = aDecoder.decodeObject(forKey: PropertyKey.board) as? Board else
        {
            return nil
        }
        self.board = board
        
        // Light Unbuilt Buildings
        guard let lightUnbuiltBuildings = aDecoder.decodeObject(forKey: PropertyKey.lightUnbuiltBuildings) as? Set<Building> else
        {
            return nil
        }
        self.lightUnbuiltBuildings = lightUnbuiltBuildings
        
        // Dark Unbuilt Buildings
        guard let darkUnbuiltBuildings = aDecoder.decodeObject(forKey: PropertyKey.darkUnbuiltBuildings) as? Set<Building> else
        {
            return nil
        }
        self.darkUnbuiltBuildings = darkUnbuiltBuildings
        
        // Built Pieces
        guard let builtPieces = aDecoder.decodeObject(forKey: PropertyKey.builtPieces) as? Set<Piece> else
        {
            return nil
        }
        self.builtPieces = builtPieces
        
        // Build History
        guard let buildHistory = aDecoder.decodeObject(forKey: PropertyKey.buildHistory) as? [Piece] else
        {
            return nil
        }
        self.buildHistory = buildHistory
        
        // Cathedral Built
        guard let cathedralBuilt = aDecoder.decodeObject(forKey: PropertyKey.cathedralBuilt) as? Bool else
        {
            return nil
        }
        self.cathedralBuilt = cathedralBuilt
        
        // Light Claimed Addresses
        guard let lightClaimedAddresses = aDecoder.decodeObject(forKey: PropertyKey.lightClaimedAddresses) as? Set<Address> else
        {
            return nil
        }
        self.lightClaimedAddresses = lightClaimedAddresses
        
        // Dark Claimed Addresses
        guard let darkClaimedAddresses = aDecoder.decodeObject(forKey: PropertyKey.darkClaimedAddresses) as? Set<Address> else
        {
            return nil
        }
        self.darkClaimedAddresses = darkClaimedAddresses
        
        // Next Turn
        self.nextTurn = aDecoder.decodeObject(forKey: PropertyKey.nextTurn) as? Owner
    }
}
