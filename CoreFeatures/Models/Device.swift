//
//  Device.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//
import Foundation
import CoreBluetooth

struct Device {
    let uuid: CBUUID
    let name: String
    let advertisementData: [String: Any]?
    let rssi: NSNumber?
    let peripheral: CBPeripheral?
    var isConnected: Bool?
    let isCentral: Bool
    
    init(uuid: CBUUID, name: String, advertisementData: [String : Any]? = nil, rssi: NSNumber? = nil, peripheral: CBPeripheral? = nil, central: CBCentral? = nil, isConnected: Bool? = nil, isCentral: Bool) {
        self.uuid = uuid
        self.name = name
        self.advertisementData = advertisementData
        self.rssi = rssi
        self.peripheral = peripheral
        self.isConnected = isConnected
        self.isCentral = isCentral
    }
}
