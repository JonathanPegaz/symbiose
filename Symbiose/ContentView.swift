//
//  ContentView.swift
//  Symbiose
//
//  Created by Jonathan Pegaz on 21/12/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bleInterface:BLEObservable
    @State var connectionString = "No device connected"
    @State var connectionStateSpheroLabel = "No sphero connected"
    @StateObject var bleController : BLEController = BLEController()
    var body: some View {
        VStack {
            Button(connectionString) {
                bleInterface.startScann()
            }
            Text(connectionStateSpheroLabel)
            Text("message")
            Text(bleController.messageLabel)
            Text("read")
            Text(bleController.readValueLabel)
            Text("write")
            Text(bleController.writeValueLabel)
                .onAppear(){
                    SharedToyBox.instance.searchForBoltsNamed(["SB-92B2"]) { err in
                        if err == nil {
                            connectionStateSpheroLabel = "Connected"
                        }
                    }
//                    bleController.load()
                }
        }.onChange(of: bleInterface.connectedPeripheral) { newValue in
            if let p = newValue{
                connectionString = p.name
                bleInterface.sendData()
                bleInterface.readData()
                bleInterface.listen { r in
                    print(r)
                }
            }
        }.onChange(of: bleInterface.rfid1) { newValue in
            SharedToyBox.instance.bolt!.rotateAim(90)
            SharedToyBox.instance.bolt!.drawMatrix(fillFrom: Pixel(x: 0, y: 0), to: Pixel(x: 8, y: 2), color: .red)
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
