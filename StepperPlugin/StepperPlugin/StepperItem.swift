//
//  StepperItem.swift
//  StepperPlugin
//
//  Created by Matt Brooke-Smith on 03/11/2022.
//

import Foundation

public struct StepperItem: Codable, Identifiable {
    public let id: String
    public let sfSymbolName: String
    public let title: String
    public let text: String
    public let style: String
    public var userDefaultsKey: String?
}
