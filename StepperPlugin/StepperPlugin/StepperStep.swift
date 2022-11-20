//
//  StepperStep.swift
//  StepperPlugin
//
//

import Foundation
import MobileWorkflowCore
import SwiftUI

public class StepperStep: ObservableStep, StepperItemConfiguration {
    var stepperItems: [StepperItem]
    public init(identifier: String, session: Session, services: StepServices, stepperItems: [StepperItem]) {
        self.stepperItems = stepperItems
        super.init(identifier: identifier, session: session, services: services)
    }

    public override func instantiateViewController() -> StepViewController {
        StepperStepViewController(step: self)
    }
}

extension StepperStep: BuildableStep {
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        let stepsContent = stepInfo.data.content["steps"] as? [[String: Any]] ?? []
        let stepperItems: [StepperItem] = try stepsContent.map {
            return try makeStepperItem(with: $0)
        }
        
        return StepperStep(identifier: stepInfo.data.identifier, session: stepInfo.session, services: services, stepperItems: stepperItems)
    }
}

public class StepperStepViewController: MWStepViewController {
    public override var titleMode: StepViewControllerTitleMode { .largeTitle }
    var stepperStep: StepperStep { self.step as! StepperStep }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.addCovering(childViewController: UIHostingController(
            rootView: ARStepperView(viewModel: ARStepModel(stepperItems: self.stepperStep.stepperItems), theme: stepperStep.theme ).environmentObject(self.stepperStep)
        ))
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserDefaults.standard.set("primary", forKey: "getMarried.style")
    }
    
}
