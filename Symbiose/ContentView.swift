//
//  ContentView.swift
//  Symbiose
//
//  Created by Jonathan Pegaz on 21/12/2022.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var spheroSensorController: SpheroSensorControl = SpheroSensorControl()
    
    @StateObject var BLEmac1 = BLEObservableMac1()
    @StateObject var BLEmac3 = BLEObservableMac3()
    
    @StateObject var videoManager = VideoManager()
    
    @StateObject var BLEesp1:BLEObservableEsp1 = BLEObservableEsp1()
    @StateObject var BLEesp2:BLEObservableEsp2 = BLEObservableEsp2()
    @StateObject var BLEesp2_3:BLEObservableEsp2_3 = BLEObservableEsp2_3()
    
    @StateObject var bleController : BLEController = BLEController()
    
    @State var startisReady:Bool = true
    @State var step1isReady:Bool = false
    @State var step2isReady:Bool = false
    @State var step3isReady:Bool = false
    @State var step4isReady:Bool = false
    @State var cheatStep3:Bool = false

    @State var connectionStringble1 = "No esp1 connected"
    @State var connectionStringble2 = "No esp2 connected"
    @State var connectionStringble3 = "No esp3 connected"
    @State var connectionStateSpheroLabel = "No sphero connected"
    
    
    var body: some View {
        VStack {
            CustomVideoPlayer(player: videoManager.player).edgesIgnoringSafeArea(.all)
                .onAppear(){
                    bleController.load()
                    
                }
                
            
//            Text(connectionStringble1)
//            Text(connectionStringble2)
//            Text(connectionStringble3)
//            Text(connectionStateSpheroLabel)
//            Button("act 3") {
//                BLEmac3.startScann()
//                BLEesp2_3.sendString(str: "runningAct3")
//            }
//            Button("fin act 1") {
//                BLEmac1.mac1value = "endact1"
//            }
//            Button("fin act 2") {
//                BLEesp2.esp2value = "endAct2"
//            }
//            Button("fin act 3") {
//                BLEmac3.mac3value = "endact3"
//            }
                
        }
        .onChange(of: bleController.bleStatus) { newValue in
            SharedToyBox.instance.searchForBoltsNamed(["SB-92B2"]) { err in
                if err == nil {
                    spheroSensorController.load()
                    BLEesp1.startScann()
                }
            }
        }
        .onChange(of: spheroSensorController.isShaking, perform: { newValue in
            if (newValue == true) {
                if (startisReady) {
                    videoManager.changeStep(step: 1)
                    startisReady = false
                    step1isReady = true
                }
                if (step2isReady) {
                    videoManager.changeStep(step: 2)
                    step2isReady = false
                }
                if (step3isReady) {
                    videoManager.changeStep(step: 3)
                    step3isReady = false
                }
                if (step4isReady) {
                    BLEmac3.sendString(str: "reset")
                    videoManager.changeStep(step: 4)
                    step4isReady = false
                }
                if (cheatStep3) {
                    BLEmac3.mac3value = "endact3"
                    cheatStep3 = false
                }
            }
        })
        .onChange(of: videoManager.step, perform: { newValue in
            switch newValue {
            case 1:
                print("step1")
            case 2:
                print("step2")
            case 3:
                print("step3")
            case 4:
                print("step4")
            default:
                print("erreur mauvaise valeur")
            }
        })
        .onChange(of: videoManager.currentTime) { newValue in
            if (newValue > 4 && BLEesp1.esp1Status != "running" && step1isReady) {
//                print("running")
                BLEesp1.sendString(str: "running")
                BLEmac1.sendString(str: "start")
                step1isReady = false
                
            }
            
            if (newValue > 12 && BLEesp2_3.esp2_3Status != "runningAct3" && BLEesp2_3.esp2_3Status != "runningAct2") {
//                print("runningAct2")
                BLEesp2_3.sendString(str: "runningAct2")
                BLEesp2.startScann()
            }
            
            if (newValue > 19 && BLEesp2_3.esp2_3Status != "runningAct3") {
                print("runningAct3")
                BLEmac3.sendString(str: "start")
                BLEesp2_3.sendString(str: "runningAct3")
            }
            
        }
        .onChange(of: BLEmac1.connectedPeripheral) { newValue in
            if let p = newValue{
                BLEmac1.sendString(str: "reset")
                BLEmac3.startScann()
                BLEmac1.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEmac3.connectedPeripheral) { newValue in
            if let p = newValue{
                print(p)
                connectionStringble2 = p.name
                BLEmac3.sendString(str: "reset")
                BLEmac3.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEmac1.mac1value, perform: { newValue in
            if (newValue == "endact1") {
                BLEesp1.sendString(str: "end")
                step2isReady = true
            }
        })
        .onChange(of: BLEesp2.esp2value) { newValue in
            // end act 2
            BLEesp2_3.sendString(str: newValue)
            step3isReady = true
        }
        .onChange(of: BLEmac3.mac3value, perform: { newValue in
            if (newValue == "go") {
                cheatStep3 = true
            }
            if (newValue == "endact3") {
                BLEesp2_3.sendString(str: "endact3")
                step4isReady = true
            }
        })
        .onChange(of: BLEesp1.connectedPeripheral, perform: { newValue in
            if let p = newValue{
                connectionStringble1 = p.name
                BLEesp1.sendString(str: "reset")
                BLEesp2_3.startScann()
                BLEesp1.listen { r in
                    print(r)
                }
            }
        })
        .onChange(of: BLEesp2.connectedPeripheral) { newValue in
            if let p = newValue{
                connectionStringble2 = p.name
                BLEesp2.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEesp2_3.connectedPeripheral) { newValue in
            if let p = newValue{
                connectionStringble3 = p.name
                BLEesp2_3.sendString(str: "reset")
                BLEmac1.startScann()
                BLEesp2_3.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEesp2.rfid1) { newValue in
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 0), to: Pixel(x: 7, y: 2), color: .red)
        }.onChange(of: BLEesp2.rfid2) { newValue in
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 3), to: Pixel(x: 7, y: 5), color: .blue)
        }.onChange(of: BLEesp2.rfid3) { newValue in
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 6), to: Pixel(x: 7, y: 7), color: .green)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
