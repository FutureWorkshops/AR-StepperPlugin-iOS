//
//  StepperStep.swift
//  StepperPlugin
//
//

import Foundation
import MobileWorkflowCore
import SwiftUI

public class StepperStep: ObservableStep {
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
    
    private static func makeStepperItem(with item: [String: Any]) throws -> StepperItem {
        guard let id = item.getString(key: "id") else {
            throw ParseError.invalidStepData(cause: "Invalid id for step")
        }

        guard let title = item["title"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid title for step")
        }
        
        guard let text = item["text"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid text for step")
        }
        
        guard let sfSymbolName = item["sfSymbol"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid sfSymbolName for step")
        }
        
        guard let style = item["style"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid style for step")
        }
        return StepperItem(id: id, sfSymbolName: sfSymbolName, title: title, text: text, style: style)
    }
}

public class StepperStepViewController: MWStepViewController {
    public override var titleMode: StepViewControllerTitleMode { .largeTitle }
    var stepperStep: StepperStep { self.step as! StepperStep }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.addCovering(childViewController: UIHostingController(
            rootView: ARStepperView(theme: stepperStep.theme).environmentObject(self.stepperStep)
        ))
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserDefaults.standard.set("secondary", forKey: "getMarried.style")
    }
    
}
