//
//  StepperStep.swift
//  StepperPlugin
//
//

import Foundation
import MobileWorkflowCore
import SwiftUI
import StepperView

public struct StepperItem: Codable, Identifiable {
    public let id: String
    public let sfSymbolName: String
    public let title: String
    public let text: String
    public let active: Bool
}

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
        
        guard let active = item["active"] as? Bool else {
            throw ParseError.invalidStepData(cause: "Invalid active for step")
        }
        
        return StepperItem(id: id, sfSymbolName: sfSymbolName, title: title, text: text, active: active)
    }
}

public class StepperStepViewController: MWStepViewController {
    public override var titleMode: StepViewControllerTitleMode { .largeTitle }
    var stepperStep: StepperStep { self.step as! StepperStep }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.addCovering(childViewController: UIHostingController(
            rootView: StepperStepContentView(content: self.stepperStep.stepperItems).environmentObject(self.stepperStep)
        ))
    }
    
}

public struct ARStepperIconView: View {
    public var image:Image
    public var width:CGFloat
    public var color:Color
    public var strokeColor:Color
    public var circleFillColor:Color
    
    public init(image:Image, width:CGFloat, color: Color = Color.black, strokeColor: Color = Colors.blue(.lightSky).rawValue, circleFillColor: Color) {
        self.image = image
        self.width = width
        self.color = color
        self.strokeColor = strokeColor
        self.circleFillColor = circleFillColor
    }
    
    /// provides the content and behavior of this view.
    public var body: some View {
        VStack {
            Circle()
                .foregroundColor(self.circleFillColor)
                .frame(width: width, height: width)
                .overlay(Circle()
                    .stroke(strokeColor, lineWidth: 2)
                    .overlay(image
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(self.color)
                        .frame(width: width/2, height: width/2)
                        .aspectRatio(contentMode: .fit)))
        }
    }
}


struct StepperStepContentView: View {
    @EnvironmentObject var step: StepperStep
    var navigator: Navigator { step.navigator }
    var theme: Theme { step.theme }
    @State var content: [StepperItem]
    
    var body: some View {
        ScrollView() {
            StepperView()
                .addSteps(
                    self.content.map({ step in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(step.title).font(.headline)
                                Spacer()
                                Text(step.text).font(.caption)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.body).foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navigator.continue(selecting: step)
                        }
                    })
                )
                .indicators(
                    self.content.map({ step -> StepperIndicationType<AnyView> in
                        return StepperIndicationType.custom(
                            ARStepperIconView(
                                image: Image(systemName: step.sfSymbolName),
                                width: 40,
                                color: step.active ? .white : primaryColor(),
                                strokeColor: step.active ? .white : primaryColor(),
                                circleFillColor: step.active ? primaryColor() : .white
                            ).eraseToAnyView())

                    })
                )
                // Not sure if this has any effect
                .stepLifeCycles(
                    self.content.map({ step -> StepLifeCycle in
                        if step.active {
                            return StepLifeCycle.pending
                        } else {
                            return StepLifeCycle.completed
                        }
                    })
                )
                .stepIndicatorMode(StepperMode.vertical)
                .spacing(50)
                .lineOptions(StepperLineOptions.custom(2, primaryColor()))
        }
    }
    
    @MainActor
    @Sendable private func select(item: StepperItem) async {
        navigator.continue(selecting: item)
    }
    
    private func primaryColor() -> Color {
        return Color(theme.primaryButtonColor)
    }
    
    private func primaryTextColor() -> Color {
        return Color(theme.primaryTextColor)
    }
    
    private func inactiveColor() -> Color {
        return Color.gray
    }
}


