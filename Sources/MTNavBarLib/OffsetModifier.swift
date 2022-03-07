//
//  OffsetModifier.swift
//  LoLInfo
//
//  Created by Sergey Petrov on 27.12.2021.
//

import SwiftUI

struct OffsetModifier: ViewModifier {
    @Binding var offset: CGFloat
    var coordinateSpace: CoordinateSpace = .global
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader{ geo -> Color in
//                    DispatchQueue.global(qos: .userInteractive).async {
                        let minY = geo.frame(in: coordinateSpace).minY
                        DispatchQueue.main.async {
                            offset =  minY
                        }
//                    }

                    return Color.clear
                }
                    .frame(width: UIScreen.main.bounds.width, height: 0)
                ,alignment: .top
            )
    }
}
