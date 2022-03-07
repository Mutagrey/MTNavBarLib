//
//  BlurView.swift
//  LoLInfo
//
//  Created by Sergey Petrov on 25.11.2021.
//

import SwiftUI

struct BlurView: UIViewRepresentable {

    var effect: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        BlurView(effect: .dark)
    }
}
