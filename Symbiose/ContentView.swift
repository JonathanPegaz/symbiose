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

    @State var connectionStringble1 = "No device connected"
    @State var connectionStringble2 = "No device connected"
    @State var connectionStateSpheroLabel = "No sphero connected"
    
    
    var body: some View {
        VStack {
            CustomVideoPlayer(player: videoManager.player)
            
            Text(connectionStringble1)
            Text(connectionStringble2)
            Text(connectionStateSpheroLabel)
            Button("start without sphero") {
                videoManager.changeStep(step: 1)
            }
            Button("fin act 1") {
                BLEmac1.mac1value = "endact1"
            }
            Button("fin act 2") {
                BLEesp2.esp2value = "endAct2"
            }
            Button("fin act 3") {
                BLEmac3.mac3value = "endAct3"
            }
                .onAppear(){
                    bleController.load()
                    
                }
        }.onChange(of: bleController.bleStatus) { newValue in
            SharedToyBox.instance.searchForBoltsNamed(["SB-92B2"]) { err in
                if err == nil {
                    spheroSensorController.load()
                }
            }
        }
        .onChange(of: spheroSensorController.acc, perform: { newValue in
            if (newValue > 3) {
                SharedToyBox.instance.bolt?.sensorControl.disable()
                videoManager.changeStep(step: 1)
            }
        })
        .onChange(of: videoManager.step, perform: { newValue in
            switch newValue {
            case 1:
                BLEesp1.startScann()
            case 2:
                BLEesp2_3.startScann()
            case 3:
                print("step3")
            case 4:
                print("step4")
            default:
                print("erreur mauvaise valeur")
            }
        })
        .onChange(of: videoManager.currentTime) { newValue in
            if (newValue > 4 && BLEesp1.esp1Status != "running") {
                print("running")
                BLEesp1.sendString(str: "running")
                BLEmac1.startScann()
            }
            
            if (newValue > 12 && BLEesp2_3.esp2_3Status != "runningAct2") {
                print("runningAct2")
                BLEesp2_3.sendString(str: "runningAct2")
                BLEesp2.startScann()
            }
            
            if (newValue > 19 && BLEesp2_3.esp2_3Status != "runningAct3") {
                print("runningAct3")
                BLEObservableMac3().startScann()
                BLEesp2_3.sendString(str: "runningAct3")
            }
            
        }
        .onChange(of: BLEmac1.connectedPeripheral) { newValue in
            if let p = newValue{
                BLEmac1.sendString(str: "start")
                BLEmac1.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEmac3.connectedPeripheral) { newValue in
            if let p = newValue{
                BLEmac3.sendString(str: "start")
                BLEmac3.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEmac1.mac1value, perform: { newValue in
            if (newValue == "endact1") {
                BLEesp1.sendString(str: "end")
                sleep(5)
                videoManager.changeStep(step: 2)
            }
        })
        .onChange(of: BLEesp2.esp2value) { newValue in
            // end act 2
            BLEesp2_3.sendString(str: newValue)
            sleep(5)
            videoManager.changeStep(step: 3)
        }
        .onChange(of: BLEmac3.mac3value, perform: { newValue in
            if (newValue == "endAct3") {
                BLEesp2_3.sendString(str: "endAct3")
                sleep(5)
                videoManager.changeStep(step: 4)
            }
        })
        .onChange(of: BLEesp1.connectedPeripheral, perform: { newValue in
            if let p = newValue{
                BLEesp1.sendString(str: "reset")
                BLEesp1.listen { r in
                    print(r)
                }
            }
        })
        .onChange(of: BLEesp2.connectedPeripheral) { newValue in
            if let p = newValue{
                connectionStringble1 = p.name
                BLEesp2.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEesp2_3.connectedPeripheral) { newValue in
            if let p = newValue{
                BLEesp2_3.sendString(str: "reset")
                BLEesp2_3.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEesp2.rfid1) { newValue in
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 0), to: Pixel(x: 7, y: 2), color: .red)
            SharedToyBox.instance.bolt!.rotateAim(180)
        }.onChange(of: BLEesp2.rfid2) { newValue in
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 3), to: Pixel(x: 7, y: 5), color: .blue)
            SharedToyBox.instance.bolt!.rotateAim(180)
        }.onChange(of: BLEesp2.rfid3) { newValue in
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 6), to: Pixel(x: 7, y: 7), color: .green)
            SharedToyBox.instance.bolt!.rotateAim(180)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
