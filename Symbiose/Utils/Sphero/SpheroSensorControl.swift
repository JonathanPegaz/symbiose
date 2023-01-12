//
//  SensorControlViewController.swift
//  SparkPerso
//
//  Created by AL on 01/09/2019.
//  Copyright © 2019 AlbanPerli. All rights reserved.
//

import UIKit
import simd
import AVFoundation

class SpheroSensorControl: ObservableObject{
    
    var neuralNet:FFNN? = nil
    
    
    
    var isRecording = true
    var isPredicting = false
    
    
    @Published var sentence: String = ""
    @Published var dataToDisplay: SIMD3<Double> = [0.0,0.0,0.0]
    @Published var valueSphero: Float = 0.0
    
    @Published var orientation: Float = 0.0
    @Published var acc: Float = 0.0

    
    func load() {

        
        // Do any additional setup after loading the view.
        neuralNet = FFNN(inputs: 1800, hidden: 20, outputs: 3, learningRate: 0.3, momentum: 0.2, weights: nil, activationFunction: .Sigmoid, errorFunction:.crossEntropy(average: false))// .default(average: true))
        
        var currentAccData = [Double]()
        
        SharedToyBox.instance.bolt?.sensorControl.enable(sensors: SensorMask.init(arrayLiteral: .accelerometer,.gyro,.orientation,.locator))
        SharedToyBox.instance.bolt?.sensorControl.interval = 1
        SharedToyBox.instance.bolt?.setStabilization(state: SetStabilization.State.off)
        SharedToyBox.instance.bolt?.sensorControl.onDataReady = { data in
            DispatchQueue.main.async {
                
                if self.isRecording || self.isPredicting {
                    
                    
                    if let orientation = data.orientation {
//                    print("Orientation : Roll:\(orientation.roll!), pitch:\(orientation.pitch!), yaw:\(orientation.yaw!)")
                        self.orientation = Float(orientation.roll!)
                    }
                    
                    if let gyro = data.gyro {
                        if let rot = gyro.rotationRate{
                            print(Float(abs(gyro.rotationRate.x) + abs(gyro.rotationRate.y) + abs(gyro.rotationRate.z)))
                        }
                    }
 
                    if let acceleration = data.accelerometer?.filteredAcceleration {
                        // PAS BIEN!!!
                        currentAccData.append(contentsOf: [acceleration.x!, acceleration.y!, acceleration.z!])

                        // Test

                        self.dataToDisplay = [acceleration.x!, acceleration.y!, acceleration.z!]
//                        print(self.dataToDisplay)
                        self.acc = Float(abs(acceleration.x!) + abs(acceleration.y!) + abs(acceleration.z!))
                        
                        
                        
                        
//                        if absSum > 4 {
//                            self.valueSphero += absSum
//                        }
//                        print("lalalalala \(self.valueSphero)")
//                        if self.valueSphero > 100 {
//                            print("braval")
//                            self.sentence = "BRAVOOOOOOO"
//                        }
                        
                    }
                }
            }
        }
        
    }
    
    
//    func trainNetwork() {
//
//        // --------------------------------------
//        // TRAINING
//        // --------------------------------------
//        for i in 0...20 {
//            print(i)
//            if let selectedClass = movementData.randomElement(),
//                let input = selectedClass.value.randomElement(){
//                let expectedResponse = selectedClass.key.neuralNetResponse()
//
//                let floatInput = input.map{ Float($0) }
//                let floatRes = expectedResponse.map{ Float($0) }
//
//                try! neuralNet?.update(inputs: floatInput) // -> [0.23,0.67,0.99]
//                try! neuralNet?.backpropagate(answer: floatRes)
//
//            }
//        }
//
//        // --------------------------------------
//        // VALIDATION
//        // --------------------------------------
//        for k in movementData.keys {
//            print("Inference for \(k)")
//            let values = movementData[k]!
//            for v in values {
//                let floatInput = v.map{ Float($0) }
//                let prediction = try! neuralNet?.update(inputs:floatInput)
//                print(prediction!)
//            }
//        }
//
//    }
    
    func viewWillDisappear(_ animated: Bool) {
        SharedToyBox.instance.bolt?.sensorControl.disable()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
