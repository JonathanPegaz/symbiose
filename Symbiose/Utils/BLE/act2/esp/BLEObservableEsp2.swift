//
//  BLEObservable.swift
//  SwiftUI_BLE
//
//  Created by Al on 26/10/2022.
//

import Foundation
import CoreBluetooth

class BLEObservableEsp2:ObservableObject{
    
    enum ConnectionState {
        case disconnected,connecting,discovering,ready
    }
    
    @Published var periphList:[Periph] = []
    @Published var connectedPeripheral:Periph? = nil
    @Published var connectionState:ConnectionState = .disconnected
    @Published var dataReceived:[DataReceived] = []
    
    @Published var rfid1: Bool = false
    @Published var rfid2: Bool = false
    @Published var rfid3: Bool = false
    
    @Published var isActivated: Bool = false
    
    init(){
        _ = BLEManagerMac1.instance
    }
    
    func startScann(){
        BLEManagerMac1.instance.scan { p,s in
            print(p)
            let periph = Periph(blePeriph: p,name: s)
            
            if periph.name == "symbiose"{
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
        BLEManagerMac1.instance.stopScan()
    }
    
    func connectTo(p:Periph){
        connectionState = .connecting
        BLEManagerMac1.instance.connectPeripheral(p.blePeriph) { cbPeriph in
            self.connectionState = .discovering
            BLEManagerMac1.instance.discoverPeripheral(cbPeriph) { cbPeriphh in
                self.connectionState = .ready
                self.connectedPeripheral = p
            }
        }
        BLEManagerMac1.instance.didDisconnectPeripheral { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
    }
    
    func disconnectFrom(p:Periph){
        
        BLEManagerMac1.instance.disconnectPeripheral(p.blePeriph) { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
        
    }
    
    func sendString(str:String){
        
        let dataFromString = str.data(using: .utf8)!
        
        BLEManagerMac1.instance.sendData(data: dataFromString) { c in
            
        }
    }
    
    func sendData(){
        let d = [UInt8]([0x00,0x01,0x02])
        let data = Data(d)
        let dataFromString = String("Toto").data(using: .utf8)
        
        BLEManagerMac1.instance.sendData(data: data) { c in
            
        }
    }
    
    func readData(){
        BLEManagerMac1.instance.readData()
    }
    
    func listen(c:((String)->())){
        
        BLEManagerMac1.instance.listenForMessages { data in
            
            if let d = data{
                if let str = String(data: d, encoding: .utf8) {
                    print(str)
                    switch str {
                    case "rfid1":
                        self.rfid1 = true
                    case "rfid2":
                        self.rfid2 = true
                    case "rfid3":
                        self.rfid3 = true
                    default:
                        print(str)
                    }
                    
                    if (self.rfid1 && self.rfid2 && self.rfid3) {
                        self.isActivated = true
                    }
                }
            }
            
//            if let d = data,
//            let s = String(data: d, encoding: .utf8){
//                self.dataReceived.append(DataReceived(content: s))
//
//                    if let doubleValue = Double(s){
//                        self.dataPoints.append(LineChartDataPoint(value: doubleValue))
//
//                        if self.dataPoints.count == 100 {
//                            print("Stop")
//                            let data = "stopAccelero".data(using: .utf8)!
//                            BLEManager.instance.sendStopData(data: data, callback: { t in
//
//                            })
//                        }
//
//                        self.points = LineChartData(dataSets: LineDataSet(dataPoints: self.dataPoints))
//                    //self.dataReceived.append(DataReceived(content: s))
//                }
//            }
        }
        
    }
    
}
