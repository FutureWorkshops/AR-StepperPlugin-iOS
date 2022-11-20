//
//  ARStepperView.swift
//  StepperPlugin
//
//  Created by Matt Brooke-Smith on 18/11/2022.
//

import SwiftUI
import StepperView
import MobileWorkflowCore

struct ARStepperView: View {
    @EnvironmentObject var step: ObservableStep
    var navigator: Navigator { step.navigator }
    var theme: Theme
    
    var body: some View {
        ScrollView() {
            StepperView()
                .addSteps(
                    self.step.stepperItems.map({ step in
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
                    self.step.stepperItems.map({ step -> StepperIndicationType<AnyView> in
                        return StepperIndicationType.custom(
                            ARStepperIconView(
                                image: Image(systemName: step.sfSymbolName),
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
        .task({
            self.step.updateStepperItemsFromUserDefaults()
        })
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
