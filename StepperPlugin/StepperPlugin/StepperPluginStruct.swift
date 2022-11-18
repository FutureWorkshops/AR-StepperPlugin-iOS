//
//  StepperPlugin.swift
//  StepperPlugin
//
//

import Foundation
import MobileWorkflowCore

public struct StepperPluginStruct: Plugin {
    public static var allStepsTypes: [StepType] {
        return StepperStepType.allCases
    }
}

enum StepperStepType: String, StepType, CaseIterable {
	case step1 = "io.app-rail.stepper.stepper"
    
    var typeName: String {
        return self.rawValue
    }
    
    var stepClass: BuildableStep.Type {
        switch self {
		case .step1: return StepperStep.self
        }
    }
}

