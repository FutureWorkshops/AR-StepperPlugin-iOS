//
//  RestStepperStep.swift
//  StepperPlugin
//
//

import Foundation
import MobileWorkflowCore
import SwiftUI

public struct RestStepperItem: Codable, Identifiable {
    public let id: String
    //Other item properties
}

public class RestStepperStep: ObservableStep {
    

    public override init(identifier: String, session: Session, services: StepServices) {
        
        super.init(identifier: identifier, session: session, services: services)
    }

    public override func instantiateViewController() -> StepViewController {
        RestStepperStepViewController(step: self)
    }
}

extension RestStepperStep: BuildableStep {


    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        
        return RestStepperStep(identifier: stepInfo.data.identifier, session: stepInfo.session, services: services)
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
    @State var content: [RestStepperItem] = [RestStepperItem(id: "RestStepperItem")]

    var body: some View {
        List(content) { item in
            Text(item.id)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture { Task { await select(item: item) }}
        }
        .refreshable(action: update)
        .task(update)
    }

    @MainActor
    @Sendable private func select(item: RestStepperItem) async {
        navigator.continue(selecting: item)
    }

    @Sendable private func update() async {
        do {
            content = try await step.get(path: "/cities")
        } catch {
            print("Unable to refresh: \(error)")
        }
    }
}

struct RestStepperStepContentViewPreviews: PreviewProvider {
    static var previews: some View {
        RestStepperStepContentView().environmentObject(RestStepperStep(
            identifier: "",
            session: Session.buildEmptySession(),
            services: StepServices.buildEmptyServices()
        ))
    }
}

