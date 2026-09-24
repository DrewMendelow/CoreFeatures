//
//  Constants.swift
//  CoreFeatures
//
//  Created by Drew Mendelow on 9/23/26.
//
import CoreBluetooth

class Constants {
    static let serviceUUID = CBUUID(string: "08D9D772-F20E-4D39-8FB3-F095AE5240B6")
    static let notifyCharacteristicUUID = CBUUID(string: "9575C1C8-49F6-42A7-B057-872AB233F8E6")
    static let centralNameUUID = CBUUID(string: "9272DA16-0A22-448D-BD39-6E8CF9EE5A04")
    static let centralName = "Drews iPhone 14"
    static let peripheralName = "Nicks iPhone"
}
