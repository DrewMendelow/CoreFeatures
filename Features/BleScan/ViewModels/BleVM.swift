//
//  ContentVM.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//
import Foundation
import SwiftUI

@Observable
final class BleVM {
    var devices: [Device] = []
    private var deviceSet: Set<String> = []
    private var bluetoothManager: BluetoothManager
    private var connectedDevicesVM: ConnectedDevicesVM
    private(set) var isScanning: Bool = false
    private(set) var startedAScan: Bool = false

    
    init(bluetoothManager: BluetoothManager, connectedDevicesVM: ConnectedDevicesVM) {
        self.bluetoothManager = bluetoothManager
        self.connectedDevicesVM = connectedDevicesVM
    }
    
    func addIfNotPresent(device: Device) {
        if (!deviceSet.contains(device.name)) {
            devices.append(device)
            deviceSet.insert(device.name)
        }
    }
    
    func scanForDevices() {
        isScanning = true
        startedAScan = true
        clearDevices()
        bluetoothManager.scanForDevices()
    }
    
    func scanForSpecificDevice() {
        isScanning = true
        startedAScan = true
        clearDevices()
        bluetoothManager.scanForSpecificDevice()
    }
    
    func stopScanning() {
        isScanning = false
        bluetoothManager.stopScanning()
    }
    
    func connect(device: Device) {
        if device.peripheral == nil { return }
        bluetoothManager.connectToDevice(peripheral: device.peripheral!)
        stopScanning()
        
        if let index = devices.firstIndex(where: { $0.name == device.name }) {
            devices[index].isConnected = true
            if (!connectedDevicesVM.devices.contains(where: { $0.name == device.name })) {
                connectedDevicesVM.devices.append(device)
            }
        }
        
        print("Connecting to device: \(device.name)")
    }
    
    func clearDevices() {
        devices.removeAll()
        deviceSet.removeAll()
    }
}
