//
//  BluetoothManager.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//

import CoreBluetooth

class BluetoothPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    var blePeripheralVM: BlePeripheralVM?
    var connectedDevicesVM: ConnectedDevicesVM?
    private let serviceUUID = Constants.serviceUUID
    private var notifyCharacteristic: CBMutableCharacteristic?
    private var nameCharacteristic: CBMutableCharacteristic?
    private var subscribedCentrals: [CBCentral] = []
    
    override init() {
        super.init()

        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        print("3. CBPeripheralManager created")
    }
    
    func peripheralManagerDidUpdateState(_ central: CBPeripheralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is available")
            
        case .poweredOff:
            print("Bluetooth is turned off")
            
        case .unauthorized:
            print("Bluetooth permission denied")
            
        case .unsupported:
            print("Bluetooth not supported")
            
        default:
            print("Bluetooth state: \(central.state.rawValue)")
        }
    }
    
    func startAdvertising() {
        let dataCharacteristic = CBMutableCharacteristic(
            type: Constants.notifyCharacteristicUUID,
            properties: [.read, .write, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        let nameCharacteristic = CBMutableCharacteristic(
            type: Constants.centralNameUUID,
            properties: [.write],
            value: nil,
            permissions: [.writeable]
        )
        
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [dataCharacteristic, nameCharacteristic]
        
        self.notifyCharacteristic = dataCharacteristic
        self.nameCharacteristic = nameCharacteristic
        peripheralManager.add(service)
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        print("Advertising stopped")
    }
    
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didAdd service: CBService,
        error: Error?
    ) {
        if let error {
            print("Failed to add service:", error)
            return
        }

        print("Service added successfully. Advertising...")

        peripheral.startAdvertising([
            CBAdvertisementDataLocalNameKey: Constants.peripheralName,
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
        ])
    }
    
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didSubscribeTo characteristic: CBCharacteristic
    ) {
        subscribedCentrals.append(central)
        print("Central \(central.identifier) subscribed to \(characteristic.uuid)")
//        print("Max notification payload: \(central.maximumUpdateValueLength) bytes")
    }

    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didUnsubscribeFrom characteristic: CBCharacteristic
    ) {
        subscribedCentrals.removeAll { $0.identifier == central.identifier }
        connectedDevicesVM?.removeDevice(uuid: CBUUID(string: central.identifier.uuidString))
        print("Central unsubscribed: \(central.identifier)")
    }

    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveRead request: CBATTRequest
    ) {
        request.value = "Hello from iPad".data(using: .utf8)
        peripheral.respond(to: request, withResult: .success)
        print("Responded to a read")
    }

    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveWrite requests: [CBATTRequest]
    ) {
        for request in requests where request.characteristic.uuid == Constants.centralNameUUID {
            guard let data = request.value,
                  let name = String(data: data, encoding: .utf8) else { continue }

            print("Central identified itself as: \(name)")
            
            Task { @MainActor in
                blePeripheralVM?.setFoundConnection(device: Device(uuid: CBUUID(string: request.central.identifier.uuidString), name: name, isCentral: true))
            }
        }
        peripheral.respond(to: requests[0], withResult: .success)
    }
    
    func sendUpdate(_ data: Data) {
        guard let characteristic = notifyCharacteristic else { return }
        let sent = peripheralManager.updateValue(
            data, for: characteristic, onSubscribedCentrals: nil
        )
        if !sent { print("Queue full — wait for peripheralManagerIsReady") }
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        // Retry your queued update here
    }
    
    func requestDisconnect() {
        guard let characteristic = notifyCharacteristic else { return }
        peripheralManager.updateValue(
            Data([0xFF]),
            for: characteristic,
            onSubscribedCentrals: nil
        )
    }
}
