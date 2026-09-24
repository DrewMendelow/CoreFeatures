//
//  ContentView.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//

import SwiftUI

struct BleView: View {
    var bluetoothManager: BluetoothManager
    @State private var bleVM: BleVM
    
    init(bluetoothManager: BluetoothManager, bleVM: BleVM) {
        self.bluetoothManager = bluetoothManager
        self.bleVM = bleVM
    }
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(bleVM.devices, id: \.name) { device in
                    Button(action: {}) {
                        HStack {
                            Text(device.name)
                            Spacer()
                            if device.isConnected ?? false {
                                Text("Connected")
                                Image(systemName: "checkmark.circle")
                                    .tint(.green)
                            } else {
                                Text("\(abs(Int(truncating: device.rssi ?? 0))) dBm")
                            }
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        if !(device.isConnected ?? false) {
                            Button {
                                bleVM.connect(device: device)
                            } label: {
                                Label("Connect", systemImage: "link")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 2) {
                        Text(bleVM.startedAScan ? (bleVM.isScanning ? "Scanning" : "Stopped") : "Tap Scan to Start")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if bleVM.startedAScan && bleVM.isScanning {
                            LoadingDotsView()
                        }
                    }
                }
            
                ToolbarItem(placement: .topBarTrailing) {
                    if !bleVM.isScanning {
                        Button(action: bleVM.scanForSpecificDevice) {
                            Text("Scan")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if !bleVM.isScanning {
                        Button(action: bleVM.scanForDevices) {
                            Text("Scan All")
                        }
                    } else {
                        Button(action: bleVM.stopScanning) {
                            Text("Stop")
                        }
                    }
                }
            }
        } detail: {
            Text("Scan for Devices")
        }
    }
}
