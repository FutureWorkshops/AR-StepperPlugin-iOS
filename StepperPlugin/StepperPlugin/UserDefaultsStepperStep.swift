//
//  StepperStep.swift
//  StepperPlugin
//
//

import Foundation
import MobileWorkflowCore
import SwiftUI

public class UserDefaultsStepperStep: ObservableStep {
    @Published var stepperItems: [StepperItem]
    
    public init(identifier: String, session: Session, services: StepServices, stepperItems: [StepperItem]) {
        self.stepperItems = stepperItems
        super.init(identifier: identifier, session: session, services: services)
    }

    public override func instantiateViewController() -> StepViewController {
        UserDefaultsStepperStepViewController(step: self)
    }
    
    public func updateStepperItemsFromUserDefaults(){
        self.stepperItems = stepperItems.map({ item in
            guard let userDefaultsKey = item.userDefaultsKey else {
                return item
            }
            
            let style = UserDefaults.standard.string(forKey: "\(userDefaultsKey).style") ?? item.style
            return StepperItem(id: item.id, sfSymbolName: item.sfSymbolName, title: item.title, text: item.text, style: style)
        })
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
        
    private static func makeStepperItem(with item: [String: Any]) throws -> StepperItem {
        guard let id = item.getString(key: "id") else {
            throw ParseError.invalidStepData(cause: "Invalid id for step")
        }

        let userDefaultsKey = item.getString(key: "userDefaultsKey")

        guard let title = item["title"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid title for step")
        }
        
        guard let style = item["style"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid title for style")
        }
        
        guard let text = item["text"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid text for step")
        }
        
        guard let sfSymbolName = item["sfSymbol"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid sfSymbolName for step")
        }
        
        return StepperItem(id: id, sfSymbolName: sfSymbolName, title: title, text: text, style: style, userDefaultsKey: userDefaultsKey)
    }
}

public class UserDefaultsStepperStepViewController: MWStepViewController {
    public override var titleMode: StepViewControllerTitleMode { .largeTitle }
    var stepperStep: UserDefaultsStepperStep { self.step as! UserDefaultsStepperStep }
    var stepperView: ARStepperView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.stepperView = ARStepperView(theme: stepperStep.theme)
        self.stepperView.environmentObject(self.stepperStep)
        self.addCovering(childViewController: UIHostingController(
            rootView: self.stepperView
        ))
    }
    
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.stepperStep.updateStepperItemsFromUserDefaults()
//        if var stepperView = self.stepperView {
//            stepperView.content = stepperStep.stepperItems
//        }
//    }
    
}
