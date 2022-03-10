//
//  SwiftUIView.swift
//  
//
//  Created by Sergey Petrov on 07.03.2022.
//

import SwiftUI

var images = ["1", "2", "3", "4", "5", "6"]

public struct ExampleMTNavBar: View {
    
    @State private var offset: CGFloat = 0
    @State private var refresh: Bool = false
    
    public init() {
        
    }
    
    public var body: some View {
        MTNavView(settings: .init(), offset: $offset, refresh: $refresh) {
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
//            GeometryReader{ geo in
//                Image("6", bundle: .module)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: geo.frame(in: .global).width, height: geo.frame(in: .global).height, alignment: .center)
//                    .cornerRadius(0)
//            }
        } topBar: {
            HStack {
                Image("4", bundle: .module)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .overlay(Circle().stroke())
                    .clipShape(Circle())
                    .padding()
                VStack(alignment: .leading, spacing: 4.0){
                    Text("Title")
                        .font(.title2)
                    Text("Subtitle")
                        .font(.title3)
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
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(Color(UIColor.secondarySystemFill))
                            .cornerRadius(20)
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
        
    }
    
}

struct ExampleMTNavBar_Previews: PreviewProvider {
    static var previews: some View {
//        NavigationView{
            ExampleMTNavBar()
//        }
    }
}
