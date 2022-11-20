//
//  StepperItemConfiguration.swift
//  StepperPlugin
//
//  Created by Igor Ferreira on 20/11/22.
//

import Foundation

protocol StepperItemConfiguration {
    static func makeStepperItem(with item: [String: Any]) throws -> StepperItem
}
extension StepperItemConfiguration {
    static func makeStepperItem(with item: [String: Any]) throws -> StepperItem {
        try JSONDecoder().decode(StepperItem.self, from: JSONSerialization.data(withJSONObject: item))
    }
}
