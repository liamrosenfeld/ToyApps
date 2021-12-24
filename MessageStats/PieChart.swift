//
//  PieChart.swift
//  MessageStats
//
//  Created by Liam Rosenfeld on 12/17/21.
//

import SwiftUI

struct PieView: View {
    @State private var selectedSlice: String?
    
    private let colors: [Color] = [.blue, .red, .green, .purple, .orange, .pink, .brown, .cyan]
    
    private let data: [String : Int]
    private let slices: [PieSliceView.Attributes]
    
    init(data: [String : Int]) {
        let sum = Double(data.values.reduce(0, +))
        var endDeg = 0.0
        var newSlices: [PieSliceView.Attributes] = []
        
        for (idx, (title, value)) in data.enumerated() {
            let degrees: Double = Double(value) * 360.0 / sum
            newSlices.append(PieSliceView.Attributes(
                title: title,
                startAngle: endDeg,
                endAngle: endDeg + degrees,
                color: colors[idx % colors.count]
            ))
            endDeg += degrees
        }
        
        self.slices = newSlices
        self.data = data
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(slices) { slice in
                    PieSliceView(attributes: slice)
                }
                .frame(width: geometry.size.width, height: geometry.size.width)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let radius = 0.5 * geometry.size.width
                            let clickPos = CGPoint(x: value.location.x - radius, y: radius - value.location.y)
                            var angle = Double(atan2(clickPos.x, clickPos.y)) - (.pi / 2)
                            if (angle < 0) {
                                angle += 2 * Double.pi
                            }
                            
                            for slice in slices {
                                if (angle < degreesToRad(slice.endAngle)) {
                                    selectedSlice = slice.title
                                    break
                                }
                            }
                        }
                )
                
                Circle()
                    .fill(.background)
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                    .onTapGesture {
                        selectedSlice = nil
                    }
                
                VStack {
                    Text(selectedSlice ?? "Total")
                        .font(.title)
                        .foregroundColor(Color.gray)
                    Text(selectedSlice != nil ?
                         String(data[selectedSlice!] ?? 0) : String(data.values.reduce(0, +))
                    ).font(.title)
                }
            }
        }
    }
}


fileprivate struct PieSliceView: View {
    let attributes: Attributes
    
    struct Attributes: Identifiable {
        var title: String
        var startAngle: Double
        var endAngle: Double
        var color: Color
        
        var id: String { title }
    }
    
    var midRadians: Double {
        return degreesToRad((attributes.startAngle + attributes.endAngle) / 2.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let sideLength = min(geometry.size.width, geometry.size.height)
                    let center = CGPoint(x: sideLength / 2, y: sideLength / 2)
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: center.x,
                        startAngle: Angle(degrees: attributes.startAngle),
                        endAngle: Angle(degrees: attributes.endAngle),
                        clockwise: false
                    )
                    
                }
                .fill(attributes.color)
                
                Text(attributes.title)
                    .font(.title2)
                    .offset(
                        x: geometry.size.width * 0.35 * CGFloat(cos(midRadians)),
                        y: geometry.size.height * 0.35 * CGFloat(sin(midRadians))
                    )
                    .foregroundColor(Color.white)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

fileprivate func degreesToRad(_ deg: Double) -> Double {
    return deg * (.pi / 180)
}

struct PieView_Previews: PreviewProvider {
    static var previews: some View {
        PieView(data: ["One": 1, "Two": 2, "Three": 3])
            .padding()
            .frame(width: 500, height: 500)
    }
}


struct PieSliceView_Previews: PreviewProvider {
    static var previews: some View {
        PieSliceView(attributes: .init(
            title: "Test",
            startAngle: 0,
            endAngle: 290,
            color: .blue
        ))
    }
}
