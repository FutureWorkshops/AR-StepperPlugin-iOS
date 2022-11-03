//
//  RestStepperStep.swift
//  StepperPlugin
//
//

import Foundation
import MobileWorkflowCore
import SwiftUI

public class RestStepperStep: ObservableStep {

    let url: String
    
    public init(identifier: String, session: Session, services: StepServices, url: String) {
        self.url = url
        super.init(identifier: identifier, session: session, services: services)
    }

    public override func instantiateViewController() -> StepViewController {
        RestStepperStepViewController(step: self)
    }
}

extension RestStepperStep: BuildableStep {
    public static var mandatoryCodingPaths: [CodingKey] {
        ["url"]
    }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        guard let url = stepInfo.data.content["url"] as? String else {
            throw ParseError.invalidStepData(cause: "Invalid url for step")
        }
        return RestStepperStep(identifier: stepInfo.data.identifier, session: stepInfo.session, services: services, url: url)
    }
}

public class RestStepperStepViewController: MWStepViewController {
    public override var titleMode: StepViewControllerTitleMode { .largeTitle }
    var restStepperStep: RestStepperStep { self.step as! RestStepperStep }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.addCovering(childViewController: UIHostingController(
            rootView: RestStepperStepContentView().environmentObject(self.restStepperStep)
        ))
    }
}

struct RestStepperStepContentView: View {
    @EnvironmentObject var step: RestStepperStep
    var navigator: Navigator { step.navigator }
    var url: String { step.url }
    @State var content: [StepperItem] = []

    var body: some View {
        List(content) { item in
            Text(item.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture { Task { await select(item: item) }}
        }
        .refreshable(action: update)
        .task(update)
    }

    @MainActor
    @Sendable private func select(item: StepperItem) async {
        navigator.continue(selecting: item)
    }

    @Sendable private func update() async {
        do {
            content = try await step.get(path: self.url)
        } catch {
            print("Unable to refresh: \(error)")
        }
    }
}

