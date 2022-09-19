//
//  ContentView.swift
//  Testaaaaa
//
//  Created by クワシマ・ユウキ on 2022/09/08.
//

import SwiftUI

struct ContentView: View {
    @StateObject var manager = Manager.shared
    @State var selected: MyModel?
    @GestureState var dragOffset = CGPoint.zero
    var body: some View {
        ZStack {
            Button("add") {
                let m = MyModel()
                manager.models.append(m)
            }
            ForEach(manager.models) { model in
                model.content()
                    .frame(width: 100, height: 100, alignment: .center)
                    .position(model.originalPosition + model.movePosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if nil == self.selected {
                                    self.selected = model
                                }
                            }
                            .updating(self.$dragOffset, body: { (value, state, transaction) in
                                state = value.translation.toCGPoint()
                                guard let selected = self.selected else {
                                    return
                                }
                                selected.movePosition = dragOffset
                            })
                            .onEnded { _ in
                                guard let selected = self.selected else {
                                    return
                                }
                                selected.originalPosition += selected.movePosition
                                selected.movePosition = CGPoint.zero
                                self.selected = nil
                            }
                    )
            }
        }
        .frame(width: 500, height: 500, alignment: .center)
    }
}

class Manager: ObservableObject {
    static var shared = Manager()
    @Published var selectedModel: MyModel?
    @Published var models: [MyModel] = []{
        willSet{
            //            self.objectWillChange.send()
        }
    }
}
class MyModel: Identifiable, ObservableObject{
    
    let id = UUID.init().uuidString
    var originalPosition: CGPoint = CGPoint(x: 100, y: 100)
    var movePosition = CGPoint.zero
    
    func content() -> AnyView {
        AnyView(
            VStack {
                Rectangle()
                    .frame(width: 20, height: 20, alignment: .center)
                Text("test")
            }
            .frame(width: 50, height: 60, alignment: .center)
        )
    }
}

extension CGSize {
    func toCGPoint() -> CGPoint {
        return CGPoint(x: self.width, y: self.height)
    }
}

extension CGPoint: AdditiveArithmetic {
    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
