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
            return StepperItem(id: item.id, sfSymbol: item.sfSymbol, title: item.title, text: item.text, style: style, userDefaultsKey: item.userDefaultsKey)
        })
    }
}

struct StepItemView: View {
    let step: StepperItem
    var onTap: (StepperItem) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(step.title).font(.headline)
                Spacer().frame(maxHeight: 8.0)
                Text(step.text).font(.caption)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.body).foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap(self.step) }
    }
}

extension StepperItem {
    var primaryStyle: Bool { style == "primary" }
    
    func indicatorView(primaryColor: Color) -> StepperIndicationType<ARStepperIconView> {
        StepperIndicationType.custom(ARStepperIconView(
            image: Image(systemName: sfSymbol),
            width: 40,
            color: primaryStyle ? .white : primaryColor,
            strokeColor: primaryStyle ? .white : primaryColor,
            circleFillColor: primaryStyle ? primaryColor : .white
        ))
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
                .addSteps(viewModel.stepperItems.map({ step in
                    StepItemView(step: step, onTap: navigator.continue(selecting:))
                }))
                .indicators(viewModel.stepperItems.map({ step in
                    step.indicatorView(primaryColor: primaryColor())
                }))
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
