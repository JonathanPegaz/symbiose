//
//  BLEObservable.swift
//  SwiftUI_BLE
//
//  Created by Al on 26/10/2022.
//

import Foundation
import CoreBluetooth

struct Periph:Identifiable,Equatable{
    var id = UUID().uuidString
    var blePeriph:CBPeripheral
    var name:String
    
}

struct DataReceived:Identifiable,Equatable{
    var id = UUID().uuidString
    var content:String
}

class BLEObservable:ObservableObject{
    
    enum ConnectionState {
        case disconnected,connecting,discovering,ready
    }
    
    @Published var periphList:[Periph] = []
    @Published var connectedPeripheral:Periph? = nil
    @Published var connectionState:ConnectionState = .disconnected
    @Published var dataReceived:[DataReceived] = []
//    var dataPoints = [LineChartDataPoint]()
//    @Published var points = LineChartData(dataSets: LineDataSet(dataPoints: []))
    
    @Published var cityDataReceived:[DataReceived] = []
    
    @Published var rfid1: Bool = false
    @Published var rfid2: String = ""
    @Published var rfid3: String = ""
    
    init(){
        _ = BLEManager.instance
    }
    
    func startScann(){
        BLEManager.instance.scan { p,s in
            print(p)
            let periph = Periph(blePeriph: p,name: s)
            print(periph.name)
            
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
        BLEManager.instance.stopScan()
    }
    
    func connectTo(p:Periph){
        connectionState = .connecting
        BLEManager.instance.connectPeripheral(p.blePeriph) { cbPeriph in
            self.connectionState = .discovering
            BLEManager.instance.discoverPeripheral(cbPeriph) { cbPeriphh in
                self.connectionState = .ready
                self.connectedPeripheral = p
            }
        }
        BLEManager.instance.didDisconnectPeripheral { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
    }
    
    func disconnectFrom(p:Periph){
        
        BLEManager.instance.disconnectPeripheral(p.blePeriph) { cbPeriph in
            if self.connectedPeripheral?.blePeriph == cbPeriph{
                self.connectionState = .disconnected
                self.connectedPeripheral = nil
            }
        }
        
    }
    
    func sendString(str:String){
        
        let dataFromString = str.data(using: .utf8)!
        
        BLEManager.instance.sendData(data: dataFromString) { c in
            
        }
    }
    
    func sendData(){
        let d = [UInt8]([0x00,0x01,0x02])
        let data = Data(d)
        let dataFromString = String("Toto").data(using: .utf8)
        
        BLEManager.instance.sendData(data: data) { c in
            
        }
    }
    
    func readData(){
        BLEManager.instance.readData()
    }
    
    func listen(c:((String)->())){
        
        BLEManager.instance.listenForMessages { data in
            
            if let d = data{
                if let str = String(data: d, encoding: .utf8) {
                    print(str)
                    if (str == "rfid1") {
                        self.rfid1 = true
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
    
    func listenForCities(c:((String)->())){
        
        BLEManager.instance.listenForCityMessages { data in
            if let d = data,
            let s = String(data: d, encoding: .utf8){
                self.cityDataReceived.append(DataReceived(content: s))
                if self.cityDataReceived.count == 4 {
                    print("Stop")
                    let data = "stopcities".data(using: .utf8)!
                    BLEManager.instance.sendStopCityData(data: data, callback: { c in
                        
                    })
                }
            }
        }
        
    }
    
}
