//
//  ContentVM.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//
import Foundation
import SwiftUI

@Observable
final class BlePeripheralVM {
    private var bluetoothManager: BluetoothPeripheralManager
    private var connectedDevicesVM: ConnectedDevicesVM
    private(set) var isAdvertising: Bool = false
    private(set) var foundConnection: Bool = false

    
    init(bluetoothManager: BluetoothPeripheralManager, connectedDevicesVM: ConnectedDevicesVM) {
        self.bluetoothManager = bluetoothManager
        self.connectedDevicesVM = connectedDevicesVM
    }
    
    func startAdvertising() {
        isAdvertising = true
        foundConnection = false
        bluetoothManager.startAdvertising()
    }
    
    func stopAdvertising() {
        isAdvertising = false
        bluetoothManager.stopAdvertising()
    }
    
    func setFoundConnection(device: Device) {
        foundConnection = true
        stopAdvertising()
        
        if (!connectedDevicesVM.devices.contains(where: { $0.name == device.name })) {
            connectedDevicesVM.devices.append(device)
        }
    }
}
