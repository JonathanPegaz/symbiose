//
//  BLEObservableAct1.swift
//  Symbiose
//
//  Created by Jonathan Pegaz on 27/12/2022.
//

import Foundation
import CoreBluetooth

class BLEObservableMac3:ObservableObject{
    
    enum ConnectionState {
        case disconnected,connecting,discovering,ready
    }
    
    @Published var periphList:[Periph] = []
    @Published var connectedPeripheral:Periph? = nil
    @Published var connectionState:ConnectionState = .disconnected
    @Published var dataReceived:[DataReceived] = []
    
    @Published var mac3value: String = ""
    
    init(){
        _ = BLEManagerMac3.instance
    }
    
    func startScann(){
        BLEManagerMac3.instance.scan { p,s in
            let periph = Periph(blePeriph: p,name: s)
            if periph.name == "symbioseact3"{
                self.connectTo(p: periph)
                self.stopScann()
                
            }
            
        }
    }
    
    func stopScann(){
        BLEManagerMac3.instance.stopScan()
    }
    
    func connectTo(p:Periph){
        connectionState = .connecting
        BLEManagerMac3.instance.connectPeripheral(p.blePeriph) { cbPeriph in
            self.connectionState = .discovering
            BLEManagerMac3.instance.discoverPeripheral(cbPeriph) { cbPeriphh in
                self.connectionState = .ready
                self.connectedPeripheral = p
            }
        }
        BLEManagerMac3.instance.didDisconnectPeripheral { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
    }
    
    func disconnectFrom(p:Periph){
        
        BLEManagerMac3.instance.disconnectPeripheral(p.blePeriph) { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
        
    }
    
    func sendString(str:String){
        
        let dataFromString = str.data(using: .utf8)!
        
        BLEManagerMac3.instance.sendData(data: dataFromString) { c in
            
        }
    }
    
    func sendData(){
        let d = [UInt8]([0x00,0x01,0x02])
        let data = Data(d)
        let dataFromString = String("Toto").data(using: .utf8)
        
        BLEManagerMac3.instance.sendData(data: data) { c in
            
        }
    }
    
    func readData(){
        BLEManagerMac3.instance.readData()
    }
    
    func listen(c:((String)->())){
        
        BLEManagerMac3.instance.listenForMessages { data in
            
            if let d = data{
                if let str = String(data: d, encoding: .utf8) {
                    self.mac3value = str
                }
            }
        }
        
    }
    
}
