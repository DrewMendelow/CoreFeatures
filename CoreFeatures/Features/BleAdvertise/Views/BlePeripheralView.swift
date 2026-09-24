//
//  ContentView.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//

import SwiftUI

struct BlePeripheralView: View {
    var bluetoothManager: BluetoothPeripheralManager
    @State private var blePeripheralVM: BlePeripheralVM
    
    init(bluetoothManager: BluetoothPeripheralManager, blePeripheralVM: BlePeripheralVM) {
        self.bluetoothManager = bluetoothManager
        self.blePeripheralVM = blePeripheralVM
    }
    
    var body: some View {
        NavigationSplitView {
            ZStack {
                if !blePeripheralVM.isAdvertising {
                    if blePeripheralVM.foundConnection {
                        ConnectedView(size: 120)
                    }
                } else {
                    SendingSignalView(size: 120)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 2) {
                        Text(blePeripheralVM.foundConnection ? "Connected!" : blePeripheralVM.isAdvertising ? "Advertising" : "Idle")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if blePeripheralVM.isAdvertising {
                            LoadingDotsView()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(blePeripheralVM.isAdvertising ? "Stop" : "Advertise") {
                        if blePeripheralVM.isAdvertising {
                            blePeripheralVM.stopAdvertising()
                        } else {
                            blePeripheralVM.startAdvertising()
                        }
                    }
                }
            }
        } detail: {
            Text("Advertise Device")
        }
    }
}
