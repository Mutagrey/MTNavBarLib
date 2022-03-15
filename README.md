# _MTNavBarLib_
##### This is the custom SwifUI `NavigationView` with sticky scrollable header.
### Features
- Sticky header
- Scalable and Scrollable header
- Custom `NavigationView`

### Requirements
- iOS 14
- Swift 5.5+
- Xcode 13.0+
### Installation

The preferred way of installing SwiftUIX is via the [Swift Package Manager](https://www.swift.org/package-manager/).

In Xcode, open your project and navigate to File → Swift Packages → Add Package Dependency...
Paste the repository URL (https://github.com/Mutagrey/MTNavBarLib.git) and click Next.

 # How to use

#### Import MTNavbarLib
``` swift
Import MTNavbarLib
```
Add `MTNavView` with `MTNavSettings`
#### MTNavSettings
``` swift
MTNavSettings(minHeight: <CGFloat>, maxHeight: <CGFloat>, cornerRadius: <CGFloat>, refreshHeight: <CGFloat>, isRefreshable: <Bool>)
```
#### MTNavView
``` swift
MTNavView(settings: <MTNavSettings>, offset: Binding<CGFloat>, refresh: Binding<Bool>) {
        // Header
    } topBar: {
        // TopBar
    } content: {
        // Scrollable content
}
```
#### Example
 ``` swift
    var images = ["1", "2", "3", "4", "5", "6"]
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
```

## License

**Free to use**
