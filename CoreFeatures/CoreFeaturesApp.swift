//
//  CoreFeaturesApp.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//

import SwiftUI
import SwiftData

@main
struct CoreFeaturesApp: App {
    @State private var bluetoothManager: BluetoothManager
    @State private var bluetoothPeripheralManager: BluetoothPeripheralManager
    @State private var connectedDevicesVM: ConnectedDevicesVM
    @State private var bleScanVM: BleVM
    @State private var blePeripheralVM: BlePeripheralVM
    
    init() {
        let bluetoothManager = BluetoothManager()
        let bluetoothPeripheralManager = BluetoothPeripheralManager()

        let connectedDevicesVM = ConnectedDevicesVM(
            bluetoothManager: bluetoothManager,
            bluetoothPeripheralManager: bluetoothPeripheralManager
        )

        let bleScanVM = BleVM(
            bluetoothManager: bluetoothManager,
            connectedDevicesVM: connectedDevicesVM
        )

        let blePeripheralVM = BlePeripheralVM(
            bluetoothManager: bluetoothPeripheralManager,
            connectedDevicesVM: connectedDevicesVM
        )
        
        bluetoothManager.bleVM = bleScanVM
        bluetoothPeripheralManager.blePeripheralVM = blePeripheralVM

        _bluetoothManager = State(initialValue: bluetoothManager)
        _bluetoothPeripheralManager = State(initialValue: bluetoothPeripheralManager)
        _connectedDevicesVM = State(initialValue: connectedDevicesVM)
        _bleScanVM = State(initialValue: bleScanVM)
        _blePeripheralVM = State(initialValue: blePeripheralVM)
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                BleView(bluetoothManager: bluetoothManager, bleVM: bleScanVM)
                    .tabItem {
                        Label("Scan", systemImage: "sensor.tag.radiowaves.forward")
                    }
                
                BlePeripheralView(bluetoothManager: bluetoothPeripheralManager, blePeripheralVM: blePeripheralVM)
                    .tabItem {
                        Label("Advertise", systemImage: "dot.radiowaves.left.and.right")
                    }
                
                ConnectedDevicesView(bluetoothManager: bluetoothManager, connectedDevicesVM: connectedDevicesVM)
                    .tabItem {
                        Label("Connected", systemImage: "link")
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
