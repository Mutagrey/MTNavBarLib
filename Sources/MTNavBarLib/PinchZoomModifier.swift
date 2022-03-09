//
//  PinchZoomModifier.swift
//  LoLInfo
//
//  Created by Sergey Petrov on 30.12.2021.
//

import SwiftUI

struct PinchZoomModifier: ViewModifier {
    @State private var offset: CGPoint = .zero
    @State private var scale: CGFloat = 0
    @State private var scalePosition: CGPoint = .zero
    @SceneStorage("isZooming") var isZooming: Bool = false
    
    func body(content: Content) -> some View {
        content
        // applying offset before scaling
            .offset(x: offset.x, y: offset.y)
        //Use UIKit Gestures for simultaneously recognize both Pinch and Pan gestures
            .overlay(
                GeometryReader{geo in
                    let size = geo.size
                    ZoomGesture(size: size, offset: $offset, scale: $scale, scalePosition: $scalePosition)
                }
            )
        // scaling content
            .scaleEffect(1 + (scale < 0 ? 0 : scale), anchor: .init(x: scalePosition.x, y: scalePosition.y))
        // make it on top
            .zIndex(scale != 0 ? 1000 : 0)
            .onChange(of: scale) { newValue in
                isZooming = (scale != 0 && offset != .zero) //true
                if scale == -1 {
                    // giving some time to finish animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        scale = 0
                    }
                }
            }
    }
}

// Zoom gesture
struct ZoomGesture: UIViewRepresentable {
    var size: CGSize
    
    @Binding var offset: CGPoint
    @Binding var scale: CGFloat
    @Binding var scalePosition: CGPoint
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // Pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(sender: )))
        view.addGestureRecognizer(pinchGesture)
        
        // Pan gesture
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(sender: ))) //UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(sender: )))
        
        panGesture.delegate = context.coordinator
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        //
    }
    
    // Handlers for gestures
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: ZoomGesture
        
        init(parent: ZoomGesture){
            self.parent = parent
        }
        
        //making pan to recognize simultaneously
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        // Pinch gesture handler
        @objc
        func handlePinch(sender: UIPinchGestureRecognizer) {
            // calculating scale
            if sender.state == .began || sender.state == .changed {
                //setting scale
                
                // removing added 1
                parent.scale = sender.scale - 1
                
                // getting the position where the user pinched and applying scale at that position
                let scalePoint = CGPoint(x: sender.location(in: sender.view).x / (sender.view?.frame.size.width ?? 1),
                                         y: sender.location(in: sender.view).y / (sender.view?.frame.size.height ?? 1))
                
                // updating scale point for only once
                parent.scalePosition = parent.scalePosition == .zero ? scalePoint : parent.scalePosition
            } else {
                //setting scale to 0
                withAnimation(.easeInOut(duration: 0.35)) {
                    parent.scale = -1
                    parent.scalePosition = .zero
                }
            }
        }
        
        // Pan gesture handler
        @objc
        func handlePan(sender: UIPanGestureRecognizer) {
            // max touches
            sender.maximumNumberOfTouches = 2
            // min scale is 1
            if (sender.state == .began || sender.state == .changed) && parent.scale > 0 {
                if let view = sender.view {
                    // getting translation
                    let translation = sender.translation(in: view)
                    parent.offset = translation
                }
            } else {
                //setting state back to normal
                withAnimation(.easeInOut(duration: 0.35)) {
                    parent.offset = .zero
                    parent.scalePosition = .zero
                }
            }
        }
    }
}
