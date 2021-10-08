//
//  ContentView.swift
//  Shared
//
//  Created by Changyeol Seo on 2021/10/06.
//

import SwiftUI
struct Item {
    let color:Color
    let value:AnyHashable
}
fileprivate let c1 = Color(white: 0.3)
fileprivate let c2 = Color.gray
fileprivate let c3 = Color.orange

fileprivate let list:[[Item]] = [
    [.init(color: c1, value: "AC"), .init(color: c1, value: "*/-"), .init(color: c1, value:"%"), .init(color: c3, value: "/")],
    [.init(color: c2, value: 7), .init(color: c2, value: 8), .init(color: c2, value:9), .init(color: c3, value: "*")],
    [.init(color: c2, value: 4), .init(color: c2, value: 5), .init(color: c2, value:6), .init(color: c3, value: "-")],
    [.init(color: c2, value: 1), .init(color: c2, value: 2), .init(color: c2, value:3), .init(color: c3, value: "+")],
    [.init(color: c2, value: 0), .init(color: c2, value: "."), .init(color: c3, value: "=")]
]

struct ContentView: View {
    @State var count = 0
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("\(Calculator.shared.stringValue)")
                    .font(.title)
                    .multilineTextAlignment(.trailing)
                    .padding(20)
#if MAC
                    .background(KeyEventHandling())
#endif
            }
                
            ForEach(0..<list.count) { i in
                HStack {
                    ForEach(0..<list[i].count) { a in
                        let item = list[i][a]
                        let str = item.value as? String ?? "\(item.value as! Int)"
                        let width:CGFloat = item.value as? Int == 0 ? 110 : 50
                        let color = item.color
                        
                        Button {
                            Calculator.shared.keyInput(key: str)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10).fill(color)
                                Text(str)
                                    .foregroundColor(.white)
                                    .padding(0.5)
                            }
                            .frame(width: width, height: 50, alignment: .center)

                        }
                        .buttonStyle(PlainButtonStyle())

                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
