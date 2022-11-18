//
//  ARStepperIconView.swift
//  StepperPlugin
//
//  Created by Matt Brooke-Smith on 03/11/2022.
//

import Foundation
import SwiftUI

public struct ARStepperIconView: View {
    public var image:Image
    public var width:CGFloat
    public var color:Color
    public var strokeColor:Color
    public var circleFillColor:Color
    
    public init(image:Image, width:CGFloat, color: Color = Color.black, strokeColor: Color = Color.blue, circleFillColor: Color) {
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
                            .aspectRatio(contentMode: .fit)
                            .padding(10)
                    ))
        }
    }
}

struct ARStepperIconView_Previews: PreviewProvider {
    static var previews: some View {
        ARStepperIconView(image: Image(systemName: "heart"), width: 40, circleFillColor: Color.blue)
    }
}
