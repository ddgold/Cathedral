//
//  CathedralTests.swift
//  CathedralTests
//
//  Created by Doug Goldstein on 1/29/19.
//  Copyright © 2019 Doug Goldstein. All rights reserved.
//

import XCTest
@testable import Cathedral

class CathedralTests: XCTestCase
{
    func sampleGame() -> Game
    {
        let game = Game()
        _ = game.buildBuilding(.cathedral, for: .church, facing: .north, at: Address(1, 3))
        _ = game.buildBuilding(.manor, for: .dark, facing: .west, at: Address(0, 7))
        _ = game.buildBuilding(.tower, for: .light, facing: .south, at: Address(8, 3))
        let expectedResult = """
                               0 1 2 3 4 5 6 7 8 9
                             0 . . . . . . . . . .
                             1 . . . . . . L L . .
                             2 . . . . . . . L L .
                             3 . . C . . . . . L .
                             4 . C C C . . . . . .
                             5 . . C . . . . . . .
                             6 . D C . . . . . . .
                             7 D D D . . . . . . .
                             8 . . . . . . . . . .
                             9 . . . . . . . . . .
                             """
        XCTAssert(game.board.description == expectedResult)
        return game
    }
    
    func testCanBuild()
    {
        let game = sampleGame()
        
        XCTAssertFalse(game.canBuildBuilding(.square, for: .dark, facing: .north, at: Address(0, 5)))
        
        
    }
    
    
    
    func testEmptyBoard()
    {
        let game = Game()
        let expectedResult = """
                               0 1 2 3 4 5 6 7 8 9
                             0 . . . . . . . . . .
                             1 . . . . . . . . . .
                             2 . . . . . . . . . .
                             3 . . . . . . . . . .
                             4 . . . . . . . . . .
                             5 . . . . . . . . . .
                             6 . . . . . . . . . .
                             7 . . . . . . . . . .
                             8 . . . . . . . . . .
                             9 . . . . . . . . . .
                             """
        XCTAssert(game.board.description == expectedResult)
    }
    
    func testGame1()
    {
        let game = Game()
        let (claimedAddresses1, claimedPiece1) = game.buildBuilding(.cathedral, for: .church, facing: .east, at: Address(3, 0))
        let expectedResult1 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 . . C . . . . . . .
                             1 C C C C . . . . . .
                             2 . . C . . . . . . .
                             3 . . . . . . . . . .
                             4 . . . . . . . . . .
                             5 . . . . . . . . . .
                             6 . . . . . . . . . .
                             7 . . . . . . . . . .
                             8 . . . . . . . . . .
                             9 . . . . . . . . . .
                             """
        XCTAssert(game.board.description == expectedResult1)
        XCTAssert(claimedAddresses1.count == 0)
        XCTAssert(claimedPiece1.count == 0)
        XCTAssert(game.cathedralBuilt == true)
        XCTAssert(game.builtPieces.count == 1)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses2, claimedPiece2) = game.buildBuilding(.tower, for: .dark, facing: .west, at: Address(3, 2))
        let expectedResult2 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 . . C . . D . . . .
                             1 C C C C D D . . . .
                             2 . . C D D . . . . .
                             3 . . . . . . . . . .
                             4 . . . . . . . . . .
                             5 . . . . . . . . . .
                             6 . . . . . . . . . .
                             7 . . . . . . . . . .
                             8 . . . . . . . . . .
                             9 . . . . . . . . . .
                             """
        XCTAssert(game.board.description == expectedResult2)
        XCTAssert(claimedAddresses2.count == 0)
        XCTAssert(claimedPiece2.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 10)
        XCTAssert(game.builtPieces.count == 2)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses3, claimedPiece3) = game.buildBuilding(.academy, for: .light, facing: .north, at: Address(5, 7))
        let expectedResult3 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 . . C . . D . . . .
                             1 C C C C D D . . . .
                             2 . . C D D . . . . .
                             3 . . . . . . . . . .
                             4 . . . . . . . . . .
                             5 . . . . . . . . . .
                             6 . . . . . . . . . .
                             7 . . . . . . L . . .
                             8 . . . . . L L . . .
                             9 . . . . . . L L . .
                             """
        XCTAssert(game.board.description == expectedResult3)
        XCTAssert(claimedAddresses3.count == 0)
        XCTAssert(claimedPiece3.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .light).count == 10)
        XCTAssert(game.builtPieces.count == 3)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses4, claimedPiece4) = game.buildBuilding(.infirmary, for: .dark, facing: .north, at: Address(0, 2))
        let expectedResult4 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 . . C . . D . . . .
                             1 C C C C D D . . . .
                             2 . D C D D . . . . .
                             3 D D D . . . . . . .
                             4 . D . . . . . . . .
                             5 . . . . . . . . . .
                             6 . . . . . . . . . .
                             7 . . . . . . L . . .
                             8 . . . . . L L . . .
                             9 . . . . . . L L . .
                             """
        XCTAssert(game.board.description == expectedResult4)
        XCTAssert(claimedAddresses4.count == 0)
        XCTAssert(claimedPiece4.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 9)
        XCTAssert(game.builtPieces.count == 4)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses5, claimedPiece5) = game.buildBuilding(.castle, for: .light, facing: .east, at: Address(9, 6))
        let expectedResult5 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 . . C . . D . . . .
                             1 C C C C D D . . . .
                             2 . D C D D . . . . .
                             3 D D D . . . . . . .
                             4 . D . . . . . . . .
                             5 . . . . . . . . . .
                             6 . . . . . . . L L L
                             7 . . . . . . L L l L
                             8 . . . . . L L l l l
                             9 . . . . . . L L l l
                             """
        XCTAssert(game.board.description == expectedResult5)
        XCTAssert(claimedAddresses5.count == 6)
        XCTAssert(claimedPiece5.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .light).count == 9)
        XCTAssert(game.builtPieces.count == 5)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses6, claimedPiece6) = game.buildBuilding(.inn, for: .dark, facing: .south, at: Address(3, 4))
        let expectedResult6 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 . D D D . . . . . .
                             5 . . . . . . . . . .
                             6 . . . . . . . L L L
                             7 . . . . . . L L l L
                             8 . . . . . L L l l l
                             9 . . . . . . L L l l
                             """
        XCTAssert(game.board.description == expectedResult6)
        XCTAssert(claimedAddresses6.count == 11)
        XCTAssert(claimedPiece6.count == 1)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 8)
        XCTAssert(game.builtPieces.count == 5)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses7, claimedPiece7) = game.buildBuilding(.stable, for: .light, facing: .north, at: Address(0, 4))
        let expectedResult7 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 L D D D . . . . . .
                             5 L . . . . . . . . .
                             6 . . . . . . . L L L
                             7 . . . . . . L L l L
                             8 . . . . . L L l l l
                             9 . . . . . . L L l l
                             """
        XCTAssert(game.board.description == expectedResult7)
        XCTAssert(claimedAddresses7.count == 0)
        XCTAssert(claimedPiece7.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .light).count == 8)
        XCTAssert(game.builtPieces.count == 6)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses8, claimedPiece8) = game.buildBuilding(.square, for: .dark, facing: .east, at: Address(2, 8))
        let expectedResult8 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 L D D D . . . . . .
                             5 L . . . . . . . . .
                             6 . . . . . . . L L L
                             7 . . . . . . L L l L
                             8 . D D . . L L l l l
                             9 . D D . . . L L l l
                             """
        XCTAssert(game.board.description == expectedResult8)
        XCTAssert(claimedAddresses8.count == 0)
        XCTAssert(claimedPiece8.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 7)
        XCTAssert(game.builtPieces.count == 7)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses9, claimedPiece9) = game.buildBuilding(.bridge, for: .light, facing: .south, at: Address(0, 9))
        let expectedResult9 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 L D D D . . . . . .
                             5 L . . . . . . . . .
                             6 . . . . . . . L L L
                             7 L . . . . . L L l L
                             8 L D D . . L L l l l
                             9 L D D . . . L L l l
                             """
        XCTAssert(game.board.description == expectedResult9)
        XCTAssert(claimedAddresses9.count == 0)
        XCTAssert(claimedPiece9.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .light).count == 7)
        XCTAssert(game.builtPieces.count == 8)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses10, claimedPiece10) = game.buildBuilding(.manor, for: .dark, facing: .south, at: Address(1, 7))
        let expectedResult10 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 d D D D . . . . . .
                             5 d D . . . . . . . .
                             6 D D . . . . . L L L
                             7 d D . . . . L L l L
                             8 d D D . . L L l l l
                             9 d D D . . . L L l l
                             """
        XCTAssert(game.board.description == expectedResult10)
        XCTAssert(claimedAddresses10.count == 5)
        XCTAssert(claimedPiece10.count == 2)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 6)
        XCTAssert(game.unbuiltBuildings(for: .light).count == 9)
        XCTAssert(game.builtPieces.count == 7)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses11, claimedPiece11) = game.buildBuilding(.tavern, for: .light, facing: .north, at: Address(8, 8))
        let expectedResult11 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 d D D D . . . . . .
                             5 d D . . . . . . . .
                             6 D D . . . . . L L L
                             7 d D . . . . L L l L
                             8 d D D . . L L l L l
                             9 d D D . . . L L l l
                             """
        XCTAssert(game.board.description == expectedResult11)
        XCTAssert(claimedAddresses11.count == 0)
        XCTAssert(claimedPiece11.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .light).count == 8)
        XCTAssert(game.builtPieces.count == 8)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses12, claimedPiece12) = game.buildBuilding(.academy, for: .dark, facing: .north, at: Address(3, 6))
        let expectedResult12 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 d D D D . . . . . .
                             5 d D . . . . . . . .
                             6 D D . . D . . L L L
                             7 d D . . D D L L l L
                             8 d D D D D L L l L l
                             9 d D D . . . L L l l
                             """
        XCTAssert(game.board.description == expectedResult12)
        XCTAssert(claimedAddresses12.count == 0)
        XCTAssert(claimedPiece12.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 5)
        XCTAssert(game.builtPieces.count == 9)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses13, claimedPiece13) = game.buildBuilding(.bridge, for: .light, facing: .east, at: Address(5, 9))
        let expectedResult13 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 d D D D . . . . . .
                             5 d D . . . . . . . .
                             6 D D . . D . . L L L
                             7 d D . . D D L L l L
                             8 d D D D D L L l L l
                             9 d D D L L L L L l l
                             """
        XCTAssert(game.board.description == expectedResult13)
        XCTAssert(claimedAddresses13.count == 0)
        XCTAssert(claimedPiece13.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .light).count == 7)
        XCTAssert(game.builtPieces.count == 10)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses14, claimedPiece14) = game.buildBuilding(.castle, for: .dark, facing: .south, at: Address(6, 6))
        let expectedResult14 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 d D D D . D D . . .
                             5 d D . . . . D . . .
                             6 D D . . D D D L L L
                             7 d D . . D D L L l L
                             8 d D D D D L L l L l
                             9 d D D L L L L L l l
                             """
        XCTAssert(game.board.description == expectedResult14)
        XCTAssert(claimedAddresses14.count == 0)
        XCTAssert(claimedPiece14.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 4)
        XCTAssert(game.builtPieces.count == 11)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses15, claimedPiece15) = game.buildBuilding(.stable, for: .light, facing: .north, at: Address(9, 8))
        let expectedResult15 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D . . . .
                             1 d d d d D D . . . .
                             2 d D d D D . . . . .
                             3 D D D D . . . . . .
                             4 d D D D . D D . . .
                             5 d D . . . . D . . .
                             6 D D . . D D D L L L
                             7 d D . . D D L L l L
                             8 d D D D D L L l L L
                             9 d D D L L L L L l L
                             """
        XCTAssert(game.board.description == expectedResult15)
        XCTAssert(claimedAddresses15.count == 0)
        XCTAssert(claimedPiece15.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .light).count == 6)
        XCTAssert(game.builtPieces.count == 12)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses16, claimedPiece16) = game.buildBuilding(.bridge, for: .dark, facing: .west, at: Address(7, 5))
        let expectedResult16 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D d d d d
                             1 d d d d D D d d d d
                             2 d D d D D d d d d d
                             3 D D D D d d d d d d
                             4 d D D D d D D d d d
                             5 d D d d d d D D D D
                             6 D D d d D D D L L L
                             7 d D d d D D L L l L
                             8 d D D D D L L l L L
                             9 d D D L L L L L l L
                             """
        XCTAssert(game.board.description == expectedResult16)
        XCTAssert(claimedAddresses16.count == 31)
        XCTAssert(claimedPiece16.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 3)
        XCTAssert(game.builtPieces.count == 13)
        XCTAssert(game.calculateWinner() == nil)
        
        
        XCTAssert(game.nextTurn == .dark)
        
        
        let (claimedAddresses17, claimedPiece17) = game.buildBuilding(.stable, for: .dark, facing: .north, at: Address(9, 0))
        let expectedResult17 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D d d d D
                             1 d d d d D D d d d D
                             2 d D d D D d d d d d
                             3 D D D D d d d d d d
                             4 d D D D d D D d d d
                             5 d D d d d d D D D D
                             6 D D d d D D D L L L
                             7 d D d d D D L L l L
                             8 d D D D D L L l L L
                             9 d D D L L L L L l L
                             """
        XCTAssert(game.board.description == expectedResult17)
        XCTAssert(claimedAddresses17.count == 0)
        XCTAssert(claimedPiece17.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 2)
        XCTAssert(game.builtPieces.count == 14)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses18, claimedPiece18) = game.buildBuilding(.abbey, for: .dark, facing: .north, at: Address(7, 0))
        let expectedResult18 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 d d d d d D d d D D
                             1 d d d d D D d D D D
                             2 d D d D D d d D d d
                             3 D D D D d d d d d d
                             4 d D D D d D D d d d
                             5 d D d d d d D D D D
                             6 D D d d D D D L L L
                             7 d D d d D D L L l L
                             8 d D D D D L L l L L
                             9 d D D L L L L L l L
                             """
        XCTAssert(game.board.description == expectedResult18)
        XCTAssert(claimedAddresses18.count == 0)
        XCTAssert(claimedPiece18.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 1)
        XCTAssert(game.builtPieces.count == 15)
        XCTAssert(game.calculateWinner() == nil)
        
        
        let (claimedAddresses19, claimedPiece19) = game.buildBuilding(.tavern, for: .dark, facing: .north, at: Address(0, 0))
        let expectedResult19 = """
                               0 1 2 3 4 5 6 7 8 9
                             0 D d d d d D d d D D
                             1 d d d d D D d D D D
                             2 d D d D D d d D d d
                             3 D D D D d d d d d d
                             4 d D D D d D D d d d
                             5 d D d d d d D D D D
                             6 D D d d D D D L L L
                             7 d D d d D D L L l L
                             8 d D D D D L L l L L
                             9 d D D L L L L L l L
                             """
        XCTAssert(game.board.description == expectedResult19)
        XCTAssert(claimedAddresses19.count == 0)
        XCTAssert(claimedPiece19.count == 0)
        XCTAssert(game.unbuiltBuildings(for: .dark).count == 0)
        XCTAssert(game.builtPieces.count == 16)
        
        
        XCTAssert(game.calculateWinner()! == (.dark, 25))
        XCTAssert(game.unbuiltBuildings(for: .dark) == [Building: Bool]())
        XCTAssert(game.unbuiltBuildings(for: .light) == [.manor: false, .tower: false, .square: false, .inn: false, .infirmary: false, .abbey: false])
    }
    

}
