//
//  AnalyticsGraph.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import SwiftUI
import Charts

struct AnalyticsGraph: View {

    @ObservedObject var viewModel: SpendingViewModel

    private var regularBar: LinearGradient {
        LinearGradient(
            colors: [
                Color("background").opacity(0.35),
                Color.gray.opacity(0.42),
                Color.white.opacity(0.75)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var maxBar: LinearGradient {
        LinearGradient(
            colors: [
                Color("background"),
                Color("accentColor").opacity(0.55),
                Color("accentColor").opacity(0.95),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        Chart {
            ForEach(viewModel.points) { point in
                BarMark(
                    x: .value("Transaction", point.plotIndex),
                    yStart: .value("Base", 0),
                    yEnd: .value("Amount", point.amount),
                    width: .fixed(10)
                )
                .foregroundStyle(point.isMonthMax ? maxBar : regularBar)
                .annotation(position: .overlay, alignment: .top, spacing: 0) {
                    Rectangle()
                        .fill(point.isMonthMax ? .red.opacity(0.8) : .white.opacity(0.75))
                        .frame(width: 9, height: 2)
                }
            }
        }
        .chartLegend(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...(viewModel.maxAmount * 1.14))
        .chartXScale(domain: 0...(viewModel.maxPlotIndex))
        .chartXAxis {
            AxisMarks(values: viewModel.weekLabelAnchors.map(\.index)) { value in
                AxisValueLabel(centered: true) {
                    if let index = value.as(Int.self),
                       let anchor = viewModel.weekLabelAnchors.first(where: { $0.index == index }) {
                        Text(anchor.label)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("primaryText").opacity(0.85))
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                if let plotFrame = proxy.plotFrame {
                    let frame = geometry[plotFrame]

                    // Solid baseline at the bottom of the plot
                    Rectangle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: frame.width+10, height: 3)
                        .position(x: frame.midX, y: frame.maxY-1)
                        .allowsHitTesting(false)

                    // Dashed max line + trailing amount
                    if let y = proxy.position(forY: viewModel.maxAmount) {
                        HStack(spacing: 8) {
                            DashedLine()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                .foregroundStyle(Color("secondaryText").opacity(0.7))
                                .frame(height: 1)

                            Text(viewModel.maxAmount.formatted(.currency(code: "USD")))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color("secondaryText"))
                        }
                        .frame(width: frame.width)
                        .position(x: frame.midX, y: frame.minY + y)
                        .allowsHitTesting(false)
                    }
                }
            }
        }
        .frame(height: 250)
    }
}

/// Horizontal line used for the dashed max line above the chart.
private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}


#Preview {
    ZStack {
        Color("background").ignoresSafeArea()
        VStack {
            AnalyticsGraph(viewModel: SpendingViewModel())
                .padding()
        }
    }
}
