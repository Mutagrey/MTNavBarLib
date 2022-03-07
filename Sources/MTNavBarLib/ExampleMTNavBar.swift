//
//  SwiftUIView.swift
//  
//
//  Created by Sergey Petrov on 07.03.2022.
//

import SwiftUI

public var images = ["1", "2", "3", "4", "5", "6"]

public struct ExampleMTNavBar: View {
    
    @State private var offset: CGFloat = 0
    
    public var body: some View {
        MTNavView(settings: .init(), offset: $offset) {
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

struct ExampleMTNavBar_Previews: PreviewProvider {
    static var previews: some View {
        ExampleMTNavBar()
    }
}
