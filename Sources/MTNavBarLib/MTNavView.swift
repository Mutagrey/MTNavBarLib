//
//  MTNavView.swift
//  MTNavBar
//
//  Created by Sergey Petrov on 06.03.2022.
//

import SwiftUI
public var images = ["1", "2", "3", "4", "5", "6"]

/// `NavSettings` settings
///
/// ```
/// public struct NavSettings {
///
///     let topHeaderHeight: CGFloat = 80
///     let progressRatio: CGFloat = 1/90
///     let cornerRadius: CGFloat = 10
///     let refreshHeight: CGFloat = 140
///     let maxHeight: CGFloat = UIScreen.main.bounds.height/2.3 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 40)
///     let enableOpacity: Bool = false
///
/// }
///```
///
public struct NavSettings {
    
    let topHeaderHeight: CGFloat
    let progressRatio: CGFloat
    let cornerRadius: CGFloat
    let refreshHeight: CGFloat
    let maxHeight: CGFloat
    let enableOpacity: Bool
    
    
    public init (topHeaderHeight: CGFloat = 80, progressRatio: CGFloat = 1/90, cornerRadius: CGFloat = 10, refreshHeight: CGFloat = 140, maxHeight: CGFloat = UIScreen.main.bounds.height/2.3 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 40), enableOpacity: Bool = false) {
        self.topHeaderHeight = topHeaderHeight
        self.progressRatio = progressRatio
        self.cornerRadius = cornerRadius
        self.refreshHeight = refreshHeight
        self.maxHeight = maxHeight
        self.enableOpacity = enableOpacity
    }
}

/// `MTNavView` represents custom `NavigationView`
/// with `ScrollView` content and Stickie Header with TopBar
///
/// The following example shows how to use it:
///
///
public struct MTNavView<Content: View, Header: View, TopBar: View>: View {
    let content: Content
    let header: Header
    let topBar: TopBar
    var settings: NavSettings = .init()
        
    @Binding var offset: CGFloat
    
    public init(settings: NavSettings, offset: Binding<CGFloat>, @ViewBuilder header: () -> Header, @ViewBuilder topBar: () -> TopBar, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.header = header()
        self.topBar = topBar()
        self.settings = settings
        self._offset = offset
    }
    
    public var body: some View {
        NavigationView {
            GeometryReader { proxy in
                let topEdge = proxy.safeAreaInsets.top
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0){
                        topNavBar(topEdge: topEdge)
                            .frame(height: settings.maxHeight - topEdge)
                            .offset(y: -offset)
                            .zIndex(1)
                        .overlay(Text("\( getTopBarOpacity(topEdge: topEdge))").foregroundColor(.white))
    //                        .id(scrollUpID)
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .modifier(OffsetModifier(offset: $offset, coordinateSpace: .named("SCROLL_Sticky_MTNavBar")))
                }
                .coordinateSpace(name: "SCROLL_Sticky_MTNavBar")
                .ignoresSafeArea(.all, edges: .top)
                
            }
            .navigationBarHidden(true)
        }
    }
    
    func defaultSettings() -> NavSettings {
        return .init()
    }
}

struct MTNavView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MTNavView(settings: .init(), offset: .constant(0)) {
            TabView{
                ForEach(images, id:\.self) { item in
                    GeometryReader{ geo in
                        Image(item, bundle: .module)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.frame(in: .global).width, height: geo.frame(in: .global).height, alignment: .center)
                            .cornerRadius(0)
                    }
                    .tag(item)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        } topBar: {
            HStack {
                Image("4", bundle: .module)
                    .resizable()
                    .frame(width: 55, height: 55)
//                    .padding()
                    .overlay(Circle().stroke())
                    .clipShape(Circle())
                    .padding()
                VStack(alignment: .leading, spacing: 4.0){
                    Text("Title")
                        .font(.title)
    //                    .padding()
                    Text("Subtitle")
                        .font(.title2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

        } content: {
            LazyVStack{
                ForEach(0 ..< 50) { item in
                    NavigationLink {
                        Text("\(item)")
                            .padding()
                            .navigationTitle("title: \(item)")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text("\(item)")
                            .padding()
                    }
                }
            }
            .background(Color.green)
        }
        .background(Color.green)

    }
}

extension MTNavView {
    private func topNavBar(topEdge: CGFloat) -> some View {
        VStack{
            GeometryReader{ geo in
                header
                    .frame(width: geo.frame(in: .global).width, height: geo.frame(in: .global).height, alignment: .bottom)
                                    .cornerRadius(getCornerRadius(topEdge: topEdge))
            }
            .opacity(getOpacity())
            .frame(height: getHeaderHeight(topEdge: topEdge), alignment: .bottom)
//            .offset(y: -topEdge)
            .overlay(
                topBar
                    .opacity(getTopBarOpacity(topEdge: topEdge))
                    .frame(height: getTopBarHeight(topEdge: topEdge)  )

                    .frame(maxWidth: .infinity)//, maxHeight: .infinity)
                                    .padding(.top, topEdge)
                    .background(BlurView(effect: .systemUltraThinMaterial).opacity(getTopBarOpacity(topEdge: topEdge)).ignoresSafeArea())
//                    .offset(y: topEdge)
                
                , alignment: .top)
            Spacer()
        }
        
    }
}

extension MTNavView {
//    func refreshStatus(_ curOffset: CGFloat) {
//        if curOffset == 0 {
//            self.frozen = false
//        }
//        if curOffset >= refreshHeight && !frozen {
//            self.frozen = true
//            self.refresh = true
//        }
//
//    }
    
    func getTopBarHeight(topEdge: CGFloat) -> CGFloat {
        let progress = (-offset  + 0) / (settings.maxHeight - (settings.topHeaderHeight + topEdge))
        return (progress < 0 ? 0 : (progress > 1 ? 1 : progress)) * settings.topHeaderHeight
    }
    
    func getHeaderHeight(topEdge: CGFloat) -> CGFloat {
        let topHeight = settings.maxHeight + offset
        return topHeight > (settings.topHeaderHeight + topEdge) ? topHeight : (settings.topHeaderHeight + topEdge)
    }
    
    func getOpacity() -> CGFloat {
        if settings.enableOpacity {
            let progress = -offset * settings.progressRatio
            let opacity = 1 - progress
            return offset < 0 ? opacity : 1
        }
        return 1
    }
    func getTopBarOpacity(topEdge: CGFloat) -> CGFloat {
        let progress = (-offset  + 0) / (settings.maxHeight - (settings.topHeaderHeight + topEdge))
        return progress
    }
    
    func getCornerRadius(topEdge: CGFloat) -> CGFloat {
        let progress = -offset / (settings.maxHeight - (settings.topHeaderHeight + topEdge))
        let value = 1 - progress
        let radius = value * settings.cornerRadius
        return offset < 0 ? radius : settings.cornerRadius
    }
    
//    func getRefreshSize(topEdge: CGFloat) -> CGFloat {
//        let progress = -offset / (settings.maxHeight - (settings.topHeaderHeight + topEdge))
//        //        let value = 1 - progress
//        let value = 35 + abs(progress * settings.cornerRadius)
//        return offset < 0 ? settings.cornerRadius : value
//    }
//    func getRotation() -> Double {
//        let progress = min(offset / settings.refreshHeight, 1)
//        let value = progress * 360
//        return Double(value)
//    }
}
