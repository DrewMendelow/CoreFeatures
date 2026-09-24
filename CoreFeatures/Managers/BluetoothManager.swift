//
//  BluetoothManager.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//

import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var bleVM: BleVM?
    private let serviceUUID = Constants.serviceUUID
    private var isConnected = false
    private var connectedPeripherals: [CBPeripheral] = []
    private var dataCharacteristic: CBCharacteristic?
    private var nameCharacteristic: CBCharacteristic?
    
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print("3. CBCentralManager created")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
    
    func scanForDevices() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func scanForSpecificDevice() {
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func connectToDevice(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect(peripheral: CBPeripheral) {
        let index = connectedPeripherals.firstIndex(where: { $0.identifier.uuidString == peripheral.identifier.uuidString})
        if isConnected && index != nil {
            isConnected = false
            centralManager.cancelPeripheralConnection(connectedPeripherals[index!])
            connectedPeripherals.remove(at: index!)
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        if (peripheral.name != nil) {
            print("Found: \(peripheral.name ?? "Unknown") RSSI: \(RSSI)dBm")
            
            Task { @MainActor in
                let device = Device(uuid: CBUUID(string: peripheral.identifier.uuidString), name: peripheral.name ?? "Unknown", advertisementData: advertisementData, rssi: RSSI, peripheral: peripheral, isConnected: false, isCentral: false)
                bleVM?.addIfNotPresent(device: device)
            }
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        isConnected = true
        if !connectedPeripherals.contains(where: { $0.identifier.uuidString == peripheral.identifier.uuidString}) {
            connectedPeripherals.append(peripheral)
        }
        print("Connected to \(peripheral.name ?? "Unknown")")
        
        centralManager.stopScan()
        peripheral.delegate = self // required for peripheral callbacks
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        print("Failed to connect: \(error?.localizedDescription ?? "unknown")")
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        print("Disconnected from \(peripheral.name ?? "Unknown")")
    }
    
    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic.uuid)")
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)   // writes the CCCD
            }
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == Constants.centralNameUUID {
                nameCharacteristic = characteristic
                sendDeviceName(to: peripheral)
            } else if (characteristic.uuid == Constants.notifyCharacteristicUUID) {
                dataCharacteristic = characteristic
            }
        }
    }
    
    func sendDeviceName(to peripheral: CBPeripheral) {
        guard let characteristic = nameCharacteristic,
              let data = Constants.centralName.data(using: .utf8) else { return }

        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard let data = characteristic.value else { return }
        if characteristic.value == Data([0xFF]) {
            disconnect(peripheral: peripheral)
        }
        print("Value: \(String(decoding: data, as: UTF8.self))")
    }
}
