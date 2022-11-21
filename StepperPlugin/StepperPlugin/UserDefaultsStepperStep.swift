//
//  StepperStep.swift
//  StepperPlugin
//
//

import Foundation
import MobileWorkflowCore
import SwiftUI

public class UserDefaultsStepperStep: ObservableStep, StepperItemConfiguration {
    @Published var stepperItems: [StepperItem]
    
    public init(identifier: String, session: Session, services: StepServices, stepperItems: [StepperItem]) {
        self.stepperItems = stepperItems
        super.init(identifier: identifier, session: session, services: services)
    }

    public override func instantiateViewController() -> StepViewController {
        UserDefaultsStepperStepViewController(step: self)
    }
}

extension UserDefaultsStepperStep: BuildableStep {
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        let stepsContent = stepInfo.data.content["steps"] as? [[String: Any]] ?? []
        let stepperItems: [StepperItem] = try stepsContent.map {
            return try makeStepperItem(with: $0)
        }
        
        return UserDefaultsStepperStep(identifier: stepInfo.data.identifier, session: stepInfo.session, services: services, stepperItems: stepperItems)
    }
}

public class UserDefaultsStepperStepViewController: MWStepViewController {
    public override var titleMode: StepViewControllerTitleMode { .largeTitle }
    var stepperStep: UserDefaultsStepperStep { self.step as! UserDefaultsStepperStep }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.addCovering(childViewController: UIHostingController(
            rootView: ARStepperView(viewModel: ARStepModel(stepperItems: self.stepperStep.stepperItems, updateFromUserDefaults: true), theme: stepperStep.theme).environmentObject(stepperStep as! ObservableStep)
        ))
    }
}
