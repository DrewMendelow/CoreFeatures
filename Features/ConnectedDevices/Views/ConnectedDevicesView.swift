//
//  ConnectedDevicesView.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//

import SwiftUI

struct ConnectedDevicesView: View {
    var bluetoothManager: BluetoothManager
    @State private var connectedDevicesVM: ConnectedDevicesVM
    
    init(bluetoothManager: BluetoothManager, connectedDevicesVM: ConnectedDevicesVM) {
        self.bluetoothManager = bluetoothManager
        self.connectedDevicesVM = connectedDevicesVM
    }
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(connectedDevicesVM.devices, id: \.name) { device in
                    Button(action: {}) {
                        HStack {
                            Text(device.name)
                            Spacer()
                            Image(systemName: "checkmark.circle")
                                .tint(.green)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            connectedDevicesVM.disconnect(device: device)
                        } label: {
                            Label("Disconnect", systemImage: "xmark.app")
                        }
                        .tint(.red)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 2) {
                        Text("Connected Devices")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
            }
        } detail: {
            Text("See Connected Devices")
        }
    }
}
