//
//  ConnectedDevicesVM.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//
import SwiftUI
import CoreBluetooth

@Observable
final class ConnectedDevicesVM {
    var devices: [Device] = []
    private var bluetoothManager: BluetoothManager
    private var bluetoothPeripheralManager: BluetoothPeripheralManager
    
    init(bluetoothManager: BluetoothManager, bluetoothPeripheralManager: BluetoothPeripheralManager) {
        self.bluetoothManager = bluetoothManager
        self.bluetoothPeripheralManager = bluetoothPeripheralManager
    }
    
    func disconnect(device: Device) {
        if device.isCentral {
            bluetoothPeripheralManager.requestDisconnect()
        } else {
            if device.peripheral != nil {
                bluetoothManager.disconnect(peripheral: device.peripheral!)
            }
        }
        
        let index = devices.firstIndex(where: { $0.name == device.name})
        if index != nil {
            devices.remove(at: index!)
        }
    }
    
    func removeDevice(uuid: CBUUID) {
        let index = devices.firstIndex(where: { $0.uuid == uuid})
        if index != nil {
            devices.remove(at: index!)
        }
    }
}
