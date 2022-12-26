//
//  BLEController.swift
//  BLEPeripheralApp
//

import UIKit
import CoreBluetooth

class BLEController: UIViewController,CBPeripheralManagerDelegate, ObservableObject {
    
    @Published var messageLabel: String = ""
    @Published var readValueLabel: String = ""
    @Published var writeValueLabel: String = ""
    
    private var service: CBUUID!
    private let value = "AD34E"
    private var peripheralManager : CBPeripheralManager!
        
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
//
//    }
    
    func load() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            print("Bluetooth Device is UNKNOWN")
        case .unsupported:
            print("Bluetooth Device is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth Device is UNAUTHORIZED")
        case .resetting:
            print("Bluetooth Device is RESETTING")
        case .poweredOff:
            print("Bluetooth Device is POWERED OFF")
        case .poweredOn:
            print("Bluetooth Device is POWERED ON")
            addServices()
        @unknown default:
            fatalError()
        }
    }

    func addServices() {
        let valueData = value.data(using: .utf8)
        
        // 1. Create instance of CBMutableCharcateristic
        let myCharacteristic1 = CBMutableCharacteristic(type: CBUUID(nsuuid: UUID()), properties: [.notify, .write, .read], value: nil, permissions: [.readable, .writeable])
        let myCharacteristic2 = CBMutableCharacteristic(type: CBUUID(nsuuid: UUID()), properties: [.read], value: valueData, permissions: [.readable])
       
        // 2. Create instance of CBMutableService
        service = CBUUID(nsuuid: UUID())
        let myService = CBMutableService(type: service, primary: true)
        
        // 3. Add characteristics to the service
        myService.characteristics = [myCharacteristic1, myCharacteristic2]
        
        // 4. Add service to peripheralManager
        peripheralManager.add(myService)
        
        // 5. Start advertising
        startAdvertising()
       
    }
    
    
    func startAdvertising() {
        messageLabel = "Advertising Data"
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey : "BLEPeripheralApp", CBAdvertisementDataServiceUUIDsKey : [service]])
        print("Started Advertising")
        
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        messageLabel = "Data getting Read"
        readValueLabel = value
      
        // Perform your additional operations here
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        messageLabel = "Writing Data"
       
        if let value = requests.first?.value {
           writeValueLabel = value.hexEncodedString2()
            //Perform here your additional operations on the data you get
        }
    }
    
    

}


extension Data {
    struct HexEncodingOptions2: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions2(rawValue: 1 << 0)
    }
    
    func hexEncodedString2(options: HexEncodingOptions2 = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
