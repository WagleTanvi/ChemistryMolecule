//
//  Atom.swift
//  moleculeBuilder
//
//  Created by Tanvi Wagle on 1/14/18.
//  Copyright © 2018 Tanvi Wagle. All rights reserved.
//

import Foundation
import UIKit

struct Atom{
    
    /*enum type: String {
        case Carbon
        case Hydrogen
        case Nitrogen
        case Oxygen
    }*/
    
    var name: String
    
    var radius: CGFloat{
        get{
            switch name {
            case "Carbon":
                return 0.43
            case "Hydrogen":
                return 0.2
            case "Oxygen":
                return 0.37
            case "Nitrogen":
                return 0.4
            default:
                return 0
            }
        }
    }
    
    var color: UIColor{
        get{
            switch name {
            case "Carbon":
                return UIColor.black
            case "Hydrogen":
                return UIColor.yellow
            case "Oxygen":
                return UIColor.red
            case "Nitrogen":
                return UIColor.blue
            default:
                return UIColor.white
            }
        }
    }
    var x: Float
    var y: Float
    var z: Float
    var maxBonds: Int{
        get{
            switch name {
            case "Carbon":
                return 4
            case "Hydrogen":
                return 1
            case "Oxygen":
                return 2
            case "Nitrogen":
                return 3
            default:
                return 0
            }
        }
    }
    func numberOfBonds() -> Int{
        var count = 1
        for (_, value) in attached{
            if (value == 1){
                count = count + 1
            }
        }
        return count
    }
    
    var attached =  ["1R": 0,"2L": 0,"3D": 0,"4U": 0]
        // 1Right, 2Left, 4Up, 3Down
    
    //mutating func updateDict(direction: String, value: Int){
        //attached[direction] = value
    //}
    /*var attached: Array<Int>{
        get{
            switch name {
            case "Carbon":
                return [0,0,0,0]
            case "Hydrogen":
                return [0]
            case "Oxygen":
                return [0,0]
            case "Nitrogen":
                return [0,0,0]
            default:
                return []
            }
        }
        // needs a setter case
    }*/
    
    
    
}
