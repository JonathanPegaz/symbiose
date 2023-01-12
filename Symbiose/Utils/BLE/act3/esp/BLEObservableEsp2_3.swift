//
//  BLEObservable.swift
//  SwiftUI_BLE
//
//  Created by Al on 26/10/2022.
//

import Foundation
import CoreBluetooth

class BLEObservableEsp2_3:ObservableObject{
    
    enum ConnectionState {
        case disconnected,connecting,discovering,ready
    }
    
    @Published var periphList:[Periph] = []
    @Published var connectedPeripheral:Periph? = nil
    @Published var connectionState:ConnectionState = .disconnected
    @Published var dataReceived:[DataReceived] = []
    
    @Published var esp2_3Status: String = ""
    
    init(){
        _ = BLEManagerEsp2_3.instance
    }
    
    func startScann(){
        BLEManagerEsp2_3.instance.scan { p,s in
            let periph = Periph(blePeriph: p,name: s)
            
            if periph.name == "esp2&3"{
//                if !self.periphList.contains(where: { per in
//                    per.blePeriph == periph.blePeriph
//                }) {
//                    self.periphList.append(periph)
//                }
                self.connectTo(p: periph)
                self.stopScann()
            }
            
        }
    }
    
    func stopScann(){
        BLEManagerEsp2_3.instance.stopScan()
    }
    
    func connectTo(p:Periph){
        connectionState = .connecting
        BLEManagerEsp2_3.instance.connectPeripheral(p.blePeriph) { cbPeriph in
            self.connectionState = .discovering
            BLEManagerEsp2_3.instance.discoverPeripheral(cbPeriph) { cbPeriphh in
                self.connectionState = .ready
                self.connectedPeripheral = p
            }
        }
        BLEManagerEsp2_3.instance.didDisconnectPeripheral { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
    }
    
    func disconnectFrom(p:Periph){
        
        BLEManagerEsp2_3.instance.disconnectPeripheral(p.blePeriph) { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
        
    }
    
    func sendString(str:String){
        
        let dataFromString = str.data(using: .utf8)!
        
        BLEManagerEsp2_3.instance.sendData(data: dataFromString) { c in
            
        }
    }
    
    func sendData(){
        let d = [UInt8]([0x00,0x01,0x02])
        let data = Data(d)
        let dataFromString = String("Toto").data(using: .utf8)
        
        BLEManagerEsp2_3.instance.sendData(data: data) { c in
            
        }
    }
    
    func readData(){
        BLEManagerEsp2_3.instance.readData()
    }
    
    func listen(c:((String)->())){
        
        BLEManagerEsp2_3.instance.listenForMessages { data in
            
            if let d = data{
                if let str = String(data: d, encoding: .utf8) {
                    print(str)
                    self.esp2_3Status = str
                }
            }

        }
        
    }
    
}
