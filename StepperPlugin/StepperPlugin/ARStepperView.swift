//
//  ARStepperView.swift
//  StepperPlugin
//
//  Created by Matt Brooke-Smith on 18/11/2022.
//

import SwiftUI
import StepperView
import MobileWorkflowCore

class ARStepModel: ObservableObject {
    @Published var stepperItems: [StepperItem]
    let updateFromUserDefaults: Bool
    
    init(stepperItems: [StepperItem], updateFromUserDefaults: Bool = false) {
        self.stepperItems = stepperItems
        self.updateFromUserDefaults = updateFromUserDefaults
    }
    
    public func updateStepperItemsFromUserDefaults(){
        guard updateFromUserDefaults else { return }
        self.stepperItems = stepperItems.map({ item in
            guard let userDefaultsKey = item.userDefaultsKey else {
                return item
            }
            
            let style = UserDefaults.standard.string(forKey: "\(userDefaultsKey).style") ?? item.style
            return StepperItem(id: item.id, sfSymbol: item.sfSymbol, title: item.title, text: item.text, style: style)
        })
    }
}

struct ARStepperView: View {
    @EnvironmentObject var step: ObservableStep
    @StateObject var viewModel: ARStepModel
    var navigator: Navigator { step.navigator }
    var theme: Theme
    
    var body: some View {
        ScrollView() {
            StepperView()
                .addSteps(
                    self.viewModel.stepperItems.map({ step in
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
                    self.viewModel.stepperItems.map({ step -> StepperIndicationType<AnyView> in
                        return StepperIndicationType.custom(
                            ARStepperIconView(
                                image: Image(systemName: step.sfSymbol),
                                width: 40,
                                color: step.style == "primary" ? .white : primaryColor(),
                                strokeColor: step.style == "primary" ? .white : primaryColor(),
                                circleFillColor: step.style == "primary" ? primaryColor() : .white
                            ).eraseToAnyView())

                    })
                )
                .stepIndicatorMode(StepperMode.vertical)
                .spacing(50)
                .lineOptions(StepperLineOptions.custom(2, primaryColor()))
        }
        .task {
            self.viewModel.updateStepperItemsFromUserDefaults()
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
