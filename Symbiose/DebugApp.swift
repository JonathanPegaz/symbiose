//
//  DebugApp.swift
//  Symbiose
//
//  Created by digital on 12/01/2023.
//

import SwiftUI

struct DebugApp: View {
        
    @StateObject var BLEmac1 = BLEObservableMac1()
    @StateObject var BLEesp1:BLEObservableEsp1 = BLEObservableEsp1()
    
    @StateObject var bleController : BLEController = BLEController()

    var body: some View {
        VStack {
            
            Button("reset act 1") {
                BLEmac1.startScann()
                BLEmac1.mac1value = "reset"
                BLEesp1.startScann()
                BLEesp1.esp1Status = "reset"
            }
            
            Button("reset screeb act 1") {
                BLEmac1.startScann()
                BLEmac1.mac1value = "reset"
            }
            
            Button("reset leds act 1") {
                BLEesp1.startScann()
                BLEesp1.esp1Status = "reset"
            }
            
        }
        .onChange(of: BLEmac1.connectedPeripheral) { newValue in
            
        }
        .onChange(of: BLEmac1.mac1value) { newValue in
            BLEmac1.sendString(str: newValue)
        }
        .onChange(of: BLEesp1.connectedPeripheral) { newValue in
           
        }
        .onChange(of: BLEesp1.esp1Status) { newValue in
            BLEesp1.sendString(str: newValue)
        }
        .padding()
    }
}

struct DebugApp_Previews: PreviewProvider {
    static var previews: some View {
        DebugApp()
    }
}
