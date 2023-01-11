//
//  ContentView.swift
//  Symbiose
//
//  Created by Jonathan Pegaz on 21/12/2022.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var BLEmac1 = BLEObservableMac1()
    @StateObject var BLEact2 = BLEObservableAct2()
    @StateObject var videoManager = VideoManager()
    
    @StateObject var BLEesp1:BLEObservableEsp1 = BLEObservableEsp1()
    
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
            Button("fin act 1") {
                BLEmac1.mac1value = "end"
            }
                .onAppear(){
                    bleController.load()
                    
                }
        }.onChange(of: bleController.bleStatus) { newValue in
            videoManager.changeStep(step: 1)
            bleController.addServices()
        }.onChange(of: videoManager.currentTime) { newValue in
            if (newValue > 3 && BLEesp1.esp1Status != "running") {
                print("running")
                BLEesp1.sendString(str: "running")
                BLEmac1.startScann()
            }
        }.onChange(of: videoManager.step, perform: { newValue in
            switch newValue {
            case 1:
                BLEesp1.startScann()
            case 2:
                SharedToyBox.instance.searchForBoltsNamed(["SB-92B2"]) { err in
                    if err == nil {
                        connectionStateSpheroLabel = "Connected"
                    }
                }
                BLEact2.startScann()
            case 3:
                print("att")
            default:
                print("erreur mauvaise valeur")
            }
        })
        .onChange(of: BLEmac1.connectedPeripheral) { newValue in
            if let p = newValue{
                BLEmac1.sendString(str: "start")
                BLEmac1.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEmac1.mac1value, perform: { newValue in
            if (newValue == "end") {
                BLEesp1.sendString(str: "end")
                sleep(5000)
                videoManager.changeStep(step: 2)
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
        .onChange(of: BLEact2.connectedPeripheral) { newValue in
            if let p = newValue{
                connectionStringble2 = p.name
                BLEact2.listen { r in
                    print(r)
                }
            }
        }
        .onChange(of: BLEact2.rfid1) { newValue in
            SharedToyBox.instance.bolt!.rotateAim(90)
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 0), to: Pixel(x: 7, y: 2), color: .red)
            SharedToyBox.instance.bolt!.rotateAim(180)
        }.onChange(of: BLEact2.rfid2) { newValue in
            SharedToyBox.instance.bolt!.rotateAim(90)
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 3), to: Pixel(x: 7, y: 5), color: .blue)
            SharedToyBox.instance.bolt!.rotateAim(180)
        }.onChange(of: BLEact2.rfid3) { newValue in
            SharedToyBox.instance.bolt!.rotateAim(90)
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 6), to: Pixel(x: 7, y: 7), color: .green)
            SharedToyBox.instance.bolt!.rotateAim(180)
        }.onChange(of: BLEact2.isActivated) { newValue in
            videoManager.changeStep(step: 3)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
