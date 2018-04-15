//
//  ViewController.swift
//  moleculeBuilder
//
//  Created by Tanvi Wagle on 1/14/18.
//  Copyright © 2018 Tanvi Wagle. All rights reserved.
//

import UIKit
import SceneKit

class MainViewController: UIViewController {

    var atoms = [Atom] () // keeping track of the atoms in the array
    var userTapped = false // making sure the user does not click a button before clicking an atom
    var tappedIndex = -1 // which index was tapped
    let nilDict =  ["1R": 0,"2L": 0,"3D": 0,"4U": 0]// intializing dictionary for an atom
    var newDict =  ["1R": 0,"2L": 0,"3D": 0,"4U": 0]
    let cameraNode = SCNNode()

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sceneView: SCNView!
    let scene = SCNScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        atoms.append(Atom(name: "Carbon", x: -0.50 , y: 0, z: -3, attached: nilDict))// intial atom
    
        // setting up gestures and scene
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.lightGray
        sceneView.autoenablesDefaultLighting = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.allowsCameraControl = true
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // setting up camera
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x:0, y:0, z:3)
        //cameraNode.eulerAngles = SCNVector3(x:  -90 * Float((Double.pi/180.0)),y: 0 * Float((Double.pi/180.0)) ,z: 0 * Float((Double.pi/180.0)))
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
        // setting up floor
        let floor = SCNNode()
        floor.position = SCNVector3(x: 0, y: -5, z: 0)
        floor.geometry = SCNFloor()
        floor.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
        scene.rootNode.addChildNode(floor)
        
        // setting up the atoms already there
        for a in atoms{
            drawAtom(a: a)
        }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5.0
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 0)
        cameraNode.position = SCNVector3(x: 0, y: 5, z: -3)
        cameraNode.eulerAngles = SCNVector3(x:  -90 * Float((Double.pi/180.0)),y: 0 * Float((Double.pi/180.0)) ,z: 0 * Float((Double.pi/180.0)))
        
        SCNTransaction.commit()
    }
    
    @objc
    func tapped(sender :UITapGestureRecognizer) {
        // saving the index of the tapped node
        label.text = "atom selected"
        print ("hello")
        userTapped = true
        let touchLocation = sender.location(in: sceneView)
        let hitTestResults = self.sceneView.hitTest(touchLocation, options: nil)
        if !hitTestResults.isEmpty {
            for hitResult in hitTestResults{
                tappedIndex = returnAtom(hitResult.node) //print (hitResult.node.name!)
            }
        }
    }
    
    @objc
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer){
        print(pinchRecognizer.scale)
        pinchRecognizer.scale = 1
    }
    
    /*@objc
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer){
        print("hello")
        let zoom = pinchRecognizer.scale
        switch pinchRecognizer.state{
        case .changed, .ended:
            sceneView.zo//cameraNode.position.z -= 0.5
        default:
            break;
        }
    }*/
    
    private func returnAtom(_ node: SCNNode) -> Int{
        
        for index in 0..<atoms.count {
            print(atoms[index].name)
            if node.position.x == atoms[index].x && node.position.y == atoms[index].y && node.position.z == atoms[index].z{
                print ("Index: \(index)")
                return index
            }
        }
        return tappedIndex
    }
    /*@IBAction func removeAtom(_ sender: UIButton) {
        if userTapped{
            if tappedIndex != -1 {
                atoms.remove(at: tappedIndex)
                userTapped = false
                label.text = "The atom you selected as been removed."
                tappedIndex = -1
                // remove bonds and update array for nearby atoms
            }
            
        }
    }*/
    @IBAction func saveImage(_ sender: UIButton) {
        let i = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(i, nil, nil, nil);
    }
    
    @IBAction func _atomSelected(_ sender: UIButton) {
        if userTapped{
            if let type = sender.currentTitle{
                //calculate the distance from current atom
                if tappedIndex != -1 {
                    if let newPos: (x: Float, y: Float, z:Float) = distance(exist: atoms[tappedIndex]){
                        let a = Atom(name: type, x: newPos.x , y: newPos.y, z: newPos.z, attached: newDict)
                        atoms.append(a)
                        drawAtom(a: a)
                        userTapped = false
                        label.text = ""
                        tappedIndex = -1
                        newDict =  ["1R": 0,"2L": 0,"3D": 0,"4U": 0]
                    }
                    
                    else {
                         label.text = "This atom is full. Please select another atom."
                         userTapped = false
                         tappedIndex = -1
                    }// in the nil case when the user presses an atom but it is already full what to do?
                }
            }
        }
        else {
            label.text = "Please select an atom to attach a bond to."
        }
    }
    private func drawBond(pos: (x: Float, y: Float, z:Float), a: Atom, rotationX: Float, rotationZ: Float){
        let newPos = calculateBondPos(pos: pos, exist: a)
        let bond = SCNNode()
        bond.geometry = SCNCylinder(radius: 0.1, height: 0.75)
        bond.position = newPos
        bond.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        bond.geometry?.firstMaterial?.specular.contents = UIColor.white
        bond.eulerAngles = SCNVector3(x: rotationX * Float((Double.pi/180.0)),y: 0 * Float((Double.pi/180.0)) ,z: rotationZ * Float((Double.pi/180)))
        scene.rootNode.addChildNode(bond)
    }
    
    private func calculateBondPos(pos: (x: Float, y: Float, z:Float), exist: Atom) -> SCNVector3  {
        let xMid = (pos.x + exist.x) / 2
        let zMid = (pos.z + exist.z) / 2
        return SCNVector3Make(xMid, pos.y, zMid)
        
    }
    
    private func distance(exist: Atom) -> (x: Float, y: Float, z: Float)?{
        // check what bonds are there
        var pos: (x: Float, y: Float, z:Float) = (exist.x,exist.y,exist.z)
        let v: Float = 1.0
        let arr = Array(exist.attached).sorted(by: {$0.0 < $1.0})
        for (key,value) in arr  {  //({$0.0 < $1.0}){
            let b = exist.numberOfBonds()
            print(b)
            print(exist.maxBonds)
            if  b <= exist.maxBonds && value == 0 {
                print ("\(key) \(value)")
                switch key{
                case "1R":
                    pos.x = pos.x + v
                    atoms[tappedIndex].attached["1R"] = 1 // REFERENCE ISSUE
                    newDict["2L"] = 1
                    drawBond(pos: pos, a: exist, rotationX: 0, rotationZ: 90)
                    return pos
                // do I change the reference to float or is it copied
                case "2L":
                    pos.x = pos.x - v
                    atoms[tappedIndex].attached["2L"] = 1
                    newDict["1R"] = 1
                    drawBond(pos: pos, a: exist, rotationX: 0, rotationZ: 90)
                    return pos
                case "4U":
                    pos.z = pos.z - v
                    atoms[tappedIndex].attached["4U"] = 1
                    newDict["3D"] = 1
                    drawBond(pos: pos, a: exist, rotationX: 90, rotationZ: 0)
                    return pos
                case "3D":
                    pos.z = pos.z + v
                    atoms[tappedIndex].attached["3D"] = 1
                    newDict["4U"] = 1
                    drawBond(pos: pos, a: exist, rotationX: 90, rotationZ: 0)
                    return pos
                default:
                    pos.x = pos.x
                }
            }
        }
        //print(pos)
        return nil
    }
    
    // draw each individual atom
    private func drawAtom(a: Atom){
        let sphereNode = SCNNode()
        sphereNode.geometry = SCNSphere(radius: a.radius)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = a.color
        sphereNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        sphereNode.position = SCNVector3Make(a.x,a.y,a.z)
        scene.rootNode.addChildNode(sphereNode)
    }
    
    
    /*override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/


}


/*if (exist.name == "Carbon"){
 let arr = Array(exist.attached).sorted(by: {$0.0 < $1.0})
 for (key,value) in arr  {   //({$0.0 < $1.0}){
 if value == 0{
 print ("\(key) \(value)")
 switch key{
 case "1R":
 pos.x = pos.x + v
 atoms[tappedIndex].attached["1R"] = 1
 newDict["2L"] = 1
 return pos
 case "2L":
 pos.x = pos.x - v
 atoms[tappedIndex].attached["2L"] = 1
 newDict["1R"] = 1
 return pos
 case "4U":
 pos.z = pos.z - v
 atoms[tappedIndex].attached["4U"] = 1
 newDict["3D"] = 1
 return pos
 case "3D":
 pos.z = pos.z + v
 atoms[tappedIndex].attached["3D"] = 1
 newDict["4U"] = 1
 return pos
 default:
 pos.x = pos.x
 }
 }
 }
 }
 
 if (exist.name == "Nitrogen"){
 let arr = Array(exist.attached).sorted(by: {$0.0 < $1.0})
 for (key,value) in arr  {  //({$0.0 < $1.0}){
 let b = exist.numberOfBonds()
 print(b)
 print(exist.maxBonds)
 if  b <= exist.maxBonds && value == 0 {
 print ("\(key) \(value)")
 switch key{
 case "1R":
 pos.x = pos.x + v
 atoms[tappedIndex].attached["1R"] = 1 // REFERENCE ISSUE
 newDict["2L"] = 1
 return pos
 // do I change the reference to float or is it copied
 case "2L":
 pos.x = pos.x - v
 atoms[tappedIndex].attached["2L"] = 1
 newDict["1R"] = 1
 return pos
 case "4U":
 pos.z = pos.z - v
 atoms[tappedIndex].attached["4U"] = 1
 newDict["3D"] = 1
 return pos
 case "3D":
 pos.z = pos.z + v
 atoms[tappedIndex].attached["3D"] = 1
 newDict["4U"] = 1
 return pos
 default:
 pos.x = pos.x
 }
 }
 }
 }
 
 if (exist.name == "Oxygen"){
 let arr = Array(exist.attached).sorted(by: {$0.0 < $1.0})
 for (key,value) in arr  {  //({$0.0 < $1.0}){
 let b = exist.numberOfBonds()
 print(b)
 print(exist.maxBonds)
 if  b <= exist.maxBonds && value == 0 {
 print ("\(key) \(value)")
 switch key{
 case "1R":
 pos.x = pos.x + v
 atoms[tappedIndex].attached["1R"] = 1 // REFERENCE ISSUE
 newDict["2L"] = 1
 return pos
 // do I change the reference to float or is it copied
 case "2L":
 pos.x = pos.x - v
 atoms[tappedIndex].attached["2L"] = 1
 newDict["1R"] = 1
 return pos
 case "4U":
 pos.z = pos.z - v
 atoms[tappedIndex].attached["4U"] = 1
 newDict["3D"] = 1
 return pos
 case "3D":
 pos.z = pos.z + v
 atoms[tappedIndex].attached["3D"] = 1
 newDict["4U"] = 1
 return pos
 default:
 pos.x = pos.x
 }
 }
 }
 }*/
