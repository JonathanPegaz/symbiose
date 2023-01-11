//
//  BLEObservableAct1.swift
//  Symbiose
//
//  Created by Jonathan Pegaz on 27/12/2022.
//

import Foundation
import CoreBluetooth

class BLEObservableEsp1:ObservableObject{
    
    enum ConnectionState {
        case disconnected,connecting,discovering,ready
    }
    
    @Published var periphList:[Periph] = []
    @Published var connectedPeripheral:Periph? = nil
    @Published var connectionState:ConnectionState = .disconnected
    @Published var dataReceived:[DataReceived] = []
    
    @Published var esp1Status:String = ""
    
    init(){
        _ = BLEManagerEsp1.instance
    }
    
    func startScann(){
        BLEManagerEsp1.instance.scan { p,s in
            let periph = Periph(blePeriph: p,name: s)
            if periph.name == "esp1"{
                self.connectTo(p: periph)
                self.stopScann()
                
            }
            
        }
    }
    
    func stopScann(){
        BLEManagerEsp1.instance.stopScan()
    }
    
    func connectTo(p:Periph){
        connectionState = .connecting
        BLEManagerEsp1.instance.connectPeripheral(p.blePeriph) { cbPeriph in
            self.connectionState = .discovering
            BLEManagerEsp1.instance.discoverPeripheral(cbPeriph) { cbPeriphh in
                self.connectionState = .ready
                self.connectedPeripheral = p
            }
        }
        BLEManagerEsp1.instance.didDisconnectPeripheral { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
    }
    
    func disconnectFrom(p:Periph){
        
        BLEManagerEsp1.instance.disconnectPeripheral(p.blePeriph) { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
        
    }
    
    func sendString(str:String){
        
        let dataFromString = str.data(using: .utf8)!
        
        BLEManagerEsp1.instance.sendData(data: dataFromString) { c in
            
        }
    }
    
    func sendData(){
        let d = [UInt8]([0x00,0x01,0x02])
        let data = Data(d)
        let dataFromString = String("Toto").data(using: .utf8)
        
        BLEManagerEsp1.instance.sendData(data: data) { c in
            
        }
    }
    
    func readData(){
        BLEManagerEsp1.instance.readData()
    }
    
    func listen(c:((String)->())){
        
        BLEManagerEsp1.instance.listenForMessages { data in
            
            if let d = data{
                if let str = String(data: d, encoding: .utf8) {
                    print(str)
                    self.esp1Status = str
                }
            }
        }
        
    }
    
}
