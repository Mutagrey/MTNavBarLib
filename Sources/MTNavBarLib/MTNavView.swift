//
//  MTNavView.swift
//  MTNavBar
//
//  Created by Sergey Petrov on 06.03.2022.
//

import SwiftUI

/// `NavSettings` settings
///
/// ```
/// public struct MTNavSettings {
///
///     let minHeight: CGFloat = 80
///     let maxHeight: CGFloat = UIScreen.main.bounds.height/2.3
///     let cornerRadius: CGFloat = 10
///     let refreshHeight: CGFloat = 140
///     let ignoreSafeArea: Bool = true
///     isRefreshable: Bool = true
///
/// }
///```
///
public struct MTNavSettings {
    
    let minHeight: CGFloat
    let maxHeight: CGFloat

    let cornerRadius: CGFloat
    let refreshHeight: CGFloat
    let isRefreshable: Bool
    let enableBlur: Bool
    let ignoreSafeArea: Bool = true
    let enableScrollUpButton: Bool
    
    public init (minHeight: CGFloat = 80, maxHeight: CGFloat = UIScreen.main.bounds.height/2.3, cornerRadius: CGFloat = 0, refreshHeight: CGFloat = 120, isRefreshable: Bool = true, enableBlur: Bool = false, enableScrollUpButton: Bool = true) {
        self.minHeight = minHeight
        self.cornerRadius = cornerRadius
        self.refreshHeight = refreshHeight
        self.maxHeight = maxHeight
        self.isRefreshable = isRefreshable
        self.enableBlur = enableBlur
        self.enableScrollUpButton = enableScrollUpButton
    }
}

/// `MTNavView` represents custom `NavigationView`
/// with `ScrollView` content and Stickie Header with TopBar
///
public struct MTNavView<Content: View, Header: View, TopBar: View>: View {
    let content: Content
    let header: Header
    let topBar: TopBar
    var settings: MTNavSettings = .init()

    @Binding var offset: CGFloat
    @Binding var refresh: Bool
    @State private var frozen: Bool = false
    
    public init(settings: MTNavSettings, offset: Binding<CGFloat>, refresh: Binding<Bool>, @ViewBuilder header: () -> Header, @ViewBuilder topBar: () -> TopBar, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.header = header()
        self.topBar = topBar()
        self.settings = settings
        self._offset = offset
        self._refresh = refresh
    }
    
    public var body: some View {
        NavigationView {
            ScrollViewReader { scroll in
                GeometryReader { proxy in
                    let topEdge = proxy.safeAreaInsets.top
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0){
                            headerView(topEdge: topEdge)
                                .frame(height: settings.maxHeight)
                                .offset(y: -offset)
                                .zIndex(1)
                                .id("SCROLL_TO_TOP")
                            if settings.isRefreshable {
                                refreshButton(topEdge: topEdge)
                            }
                            content
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .modifier(OffsetModifier(offset: $offset, coordinateSpace: .named("SCROLL_Sticky_MTNavBar")))
                    }
                    .coordinateSpace(name: "SCROLL_Sticky_MTNavBar")
                    .overlay(topBarView(topEdge: topEdge), alignment: .top)
                    .ignoresSafeArea(.all, edges: .top)
                }

                .overlay(scrollUpButton(proxy: scroll).opacity(settings.enableScrollUpButton ? 1 : 0), alignment: .bottomTrailing)

                .onChange(of: offset) { newValue in
                    DispatchQueue.main.async {
                        refreshStatus(offset)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Champions")
            .navigationBarHidden(true)
        }
    }
}

struct MTNavView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExampleMTNavBar()
            ExampleMTNavBar()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Elements View
extension MTNavView {
    
    private func headerView(topEdge: CGFloat) -> some View {
        VStack(spacing: 0){
            VStack(spacing: 0){
                if !settings.ignoreSafeArea {
                    BlurView(effect: .systemUltraThinMaterial)
                        .frame(height: topEdge)
                }
                header
            }
            .blur(radius: settings.enableBlur ? (getProgress(topEdge: topEdge) < 0 ? -getProgress(topEdge: topEdge) * 10 : 0) : 0, opaque: true)
//            .cornerRadius(getCornerRadius(topEdge: topEdge))
//            .opacity(getOpacity())
            .frame(height: getHeaderHeight(topEdge: topEdge))
            Spacer(minLength: 0)
        }
    }
    
    private func topBarView(topEdge: CGFloat) -> some View {
        GeometryReader { geo in
            topBar
                .padding(.top, topEdge )
                .background(
                    BlurView(effect: .systemUltraThinMaterial)
                        .blur(radius: getProgress(topEdge: topEdge) > 0 ? getProgress(topEdge: topEdge) * 10 : 0, opaque: true)
                )
                .opacity(getProgress(topEdge: topEdge))
                .offset(y: geo.frame(in: .global).height * getProgress(topEdge: topEdge) - geo.frame(in: .global).height)
        }
    }
}

// MARK: - Calculations
extension MTNavView {
    /// get scroll progress from -1 to 1
    func getProgress(topEdge: CGFloat) -> CGFloat {
        let progress = (-offset  - 0) / (settings.maxHeight - (settings.minHeight + topEdge))
        return (progress > 1 ? 1 : (progress < -1 ? -1 : progress) )
    }
    /// header height. it changes when scrolling from min to max height.
    func getHeaderHeight(topEdge: CGFloat) -> CGFloat {
        let topHeight = settings.maxHeight + offset //+ topEdge
        return topHeight > (settings.minHeight + topEdge) ? topHeight : (settings.minHeight + topEdge)
    }
    /// top bar height. it depends on scroll progress and shows only when progress > 0.5
    func getTopBarHeight(topEdge: CGFloat) -> CGFloat {
        let progress = (-offset  + 0) / (settings.maxHeight - (settings.minHeight + topEdge))
        return ( progress < 0 ? 0 : (progress > 1.5 ? 1 : (progress > 0.5 ? progress - 0.5 : 0) ) ) * (settings.maxHeight - settings.minHeight - topEdge)
    }
    /// cornerRadius for header
    func getCornerRadius(topEdge: CGFloat) -> CGFloat {
        let progress = -offset / (settings.maxHeight - (settings.minHeight + topEdge))
        let value = 1 - progress
        let radius = value * settings.cornerRadius
        return offset < 0 ? radius : settings.cornerRadius
    }
}

// MARK: - Refresh button
extension MTNavView {
    /// Refresh Button View
    private func refreshButton(topEdge: CGFloat) -> some View {
        let buttonHeight: CGFloat = 30
        let dh: CGFloat = 10 // extra height shift for refresh buttton
        
        return ZStack {
            if offset > 0 && offset < settings.refreshHeight && !refresh {
                Image(systemName: "goforward")
                    .resizable()
                    .foregroundColor(Color(UIColor.systemGray))
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(Angle(degrees: getRotation()))
                    .frame(width: buttonHeight, height:  buttonHeight)
                    .offset(y: offset < 0 ? getProgress(topEdge: topEdge) * buttonHeight : 0)
            } else {
                if refresh {
                    ProgressView()
                        .scaleEffect(1)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemGray)))
//                        .padding(10)
//                        .background(Color(UIColor.systemFill).cornerRadius(10))
                        .padding(.top, dh)
                    // padding compensaction. It shows ProgressView when resfresh status activated
                        .padding(.top, offset <= settings.refreshHeight ? buttonHeight + dh : 0 )
                }
            }
        }
        // It hides refreshButton, until refresh status is false
        .padding(.top, -buttonHeight - dh )
    }
    /// Rotation image
    func getRotation() -> Double {
        let refreshHeight: CGFloat = settings.refreshHeight
        let progress = min(offset / refreshHeight, 1)
        let value = progress * 360
        return Double(value)
    }
    /// Redresh status. Its frozen when
    func refreshStatus(_ curOffset: CGFloat) {
        if curOffset == 0 {
            self.frozen = false
        }
        if curOffset >= settings.refreshHeight && !frozen {
            self.frozen = true
            self.refresh = true
        }
    }
}

// MARK: - SrollUp Button
extension MTNavView {
    
    private func scrollUpButton(proxy: ScrollViewProxy) -> some View {

        Image(systemName: "chevron.up")
//            .resizable()
            .font(.headline)
            .padding()
            .background(Color(UIColor.secondarySystemFill))
            .overlay(Circle().stroke(lineWidth: 0.5))
            .clipShape(Circle())
//            .shadow(radius: 5, x: 5, y: 5)
//            .shadow(radius: 5, x: -5, y: -5)
            .padding()
            .offset(y: 130 + max(-130,offset) )
            .transition(.move(edge: .bottom))
            .onTapGesture {
                withAnimation(.spring()) {
                    proxy.scrollTo("SCROLL_TO_TOP", anchor: .top)
                }
            }
    }
}
