//
//  AnalyticsGraph.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import SwiftUI
import Charts


/*
 one bar = one `MonthlyTransaction`. transactions of a same day are placed
 side-by-side with no gap.
 different days are separated by `dayGapUnits`.
 */

struct AnalyticsGraph: View {

    @ObservedObject var viewModel: SpendingViewModel
    
    @State private var selectedBar: SelectedBar?
    
    @State private var maxLineY: CGFloat?

    // MARK: - Layout constants

    private let barWidth: CGFloat = 12
    private let dayGapUnits: Int = 1
    private let edgePaddingUnits: Int = 0
    private let chartHeight: CGFloat = 250

    // MARK: - Selection

    private struct SelectedBar: Hashable {
        let day: Int
        let indexInDay: Int
    }

    // MARK: - Gradients

    /// gradient for regualar bars.
    private var regularBar: LinearGradient {
        LinearGradient(
            colors: [
                Color("background").opacity(0.35),
                Color.gray.opacity(0.42),
                Color.white.opacity(0.75)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    // gradient for max transaction bar
    private var maxBar: LinearGradient {
        LinearGradient(
            colors: [
                Color("background"),
                Color("accentColor").opacity(0.55),
                Color("accentColor").opacity(0.95),
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    // MARK: - Layout

    /// Total x-units = bars + inter-day gaps. Drives the scrollable chart width.
    private var totalUnits: Int {
        let bars = viewModel.days.reduce(0) { $0 + $1.transactions.count }
        let gaps = max(0, viewModel.days.count - 1) * dayGapUnits
        return bars + gaps
    }

    private var chartWidth: CGFloat {
        CGFloat(totalUnits + edgePaddingUnits * 2) * barWidth
    }

    /// X domain padded by half a unit so edge bars are fully visible, not clipped.
    private var xDomain: ClosedRange<Double> {
        let lower = -Double(edgePaddingUnits) - 0.5
        let upper = Double(totalUnits + edgePaddingUnits) - 0.5
        return lower...upper
    }


    private func unitPosition(dayIndex: Int, txIndex: Int) -> Double {
        var offset = 0
        for i in 0..<dayIndex {
            offset += viewModel.days[i].transactions.count + dayGapUnits
        }
        return Double(offset + txIndex)
    }

    /// for centering the date label at the bottom of a grouped transaction
    private func dayCenterUnit(dayIndex: Int) -> Double {
        let day = viewModel.days[dayIndex]
        let first = unitPosition(dayIndex: dayIndex, txIndex: 0)
        let last  = unitPosition(dayIndex: dayIndex,
                                 txIndex: day.transactions.count - 1)
        return (first + last) / 2
    }

    // MARK: - Body


    private var fallbackMaxLineY: CGFloat {
        chartHeight * 0.14 / 1.14
    }

    var body: some View {
       
        
        ZStack(alignment: .topTrailing) {
            ScrollView(.horizontal, showsIndicators: false) {
                chart
                    .frame(width: chartWidth, height: chartHeight)
                    .padding(.bottom, 24)
            }

            if viewModel.maxAmount > 0 {
                amountBadge
                    .allowsHitTesting(false)
            }
        }
        .frame(height: chartHeight + 24)
    }

    // display amount for the selected bar.
    private var displayedAmount: Double {
        if let selected = selectedBar,
           let day = viewModel.days.first(where: { $0.day == selected.day }),
           let tx = day.transactions.first(where: { $0.indexInDay == selected.indexInDay }) {
            return tx.amount
        }
        return viewModel.maxAmount
    }


    private var amountBadge: some View {
        Text(displayedAmount.formatted(.currency(code: "USD")))
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(Color("secondaryText"))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color("background")))
            .offset(y: (maxLineY ?? fallbackMaxLineY) - 12)
    }

    // MARK: - Chart

 
    private var chart: some View {
        Chart {
            chartContent
        }
        .chartLegend(.hidden)
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        .chartYScale(domain: 0...(viewModel.maxAmount * 1.14))
        .chartXScale(domain: xDomain)
        .chartOverlay { proxy in
            overlay(proxy: proxy)
        }
        .animation(.easeInOut(duration: 0.15), value: selectedBar)
    }

    // MARK: - Chart content

    /// One `BarMark` per transaction, ordered left-to-right by day then by
    /// `indexInDay` to match `unitPosition`.
    @ChartContentBuilder
    private var chartContent: some ChartContent {
        ForEach(Array(viewModel.days.enumerated()), id: \.element.id) { pair in
            ForEach(pair.element.transactions) { tx in
                barMark(day: pair.element, tx: tx, dayIndex: pair.offset)
            }
        }
    }


    private func barMark(day: DayGroup,
                         tx: MonthlyTransaction,
                         dayIndex: Int) -> some ChartContent {
        BarMark(
            x: .value("Position", unitPosition(dayIndex: dayIndex,
                                               txIndex: tx.indexInDay)),
            yStart: .value("Base", 0),
            yEnd: .value("Amount", tx.amount),
            width: .fixed(barWidth)
        )
        .foregroundStyle(tx.isMonthMax ? maxBar : regularBar)
        .opacity(dimmedOpacity(for: day, tx: tx))
        .annotation(position: .overlay, alignment: .top, spacing: 0) {
            topHighlight(for: tx)
        }
    }

    // top cap at the top of each bar
    private func topHighlight(for tx: MonthlyTransaction) -> some View {
        Rectangle()
            .fill(tx.isMonthMax ? .red.opacity(0.8) : .white.opacity(0.75))
            .frame(width: barWidth - 1, height: 3)
    }

    // MARK: - Overlay

    /// Bridges `ChartProxy` plot coordinates to overlay views via the plot frame.
    private func overlay(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            if let plotFrame = proxy.plotFrame {
                let frame = geometry[plotFrame]
                overlayContent(frame: frame, proxy: proxy)
            }
        }
    }

    /// Overlay draw order (bottom to top): baseline, max dashed line,
    /// invisible tap target, selected-day label. Order matters so taps win
    /// over decorations but the label stays visible.
    @ViewBuilder
    private func overlayContent(frame: CGRect, proxy: ChartProxy) -> some View {
        baseline(frame: frame)
        maxLine(frame: frame, proxy: proxy)
        tapTarget(frame: frame, proxy: proxy)
        selectedLabel(frame: frame, proxy: proxy)
    }

    // the bottom baseline of the graph
    private func baseline(frame: CGRect) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.85))
            .frame(width: frame.width, height: 3)
            .position(x: frame.midX, y: frame.maxY)
            .allowsHitTesting(false)
    }

    // the top dashedline of the graph
    @ViewBuilder
    private func maxLine(frame: CGRect, proxy: ChartProxy) -> some View {
        if let y = proxy.position(forY: viewModel.maxAmount) {
            DashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(Color("secondaryText").opacity(0.7))
                .frame(width: frame.width, height: 1)
                .position(x: frame.midX, y: frame.minY + y)
                .allowsHitTesting(false)
                .onAppear {
                    maxLineY = frame.minY + y
                }
                .onChange(of: y) { _, newY in
                    maxLineY = frame.minY + newY
                }
                .onChange(of: viewModel.maxAmount) {
                    if let newY = proxy.position(forY: viewModel.maxAmount) {
                        maxLineY = frame.minY + newY
                    }
                }
        }
    }

    /// Transparent layer covering only the band from the top dashed line down
    /// to the bottom baseline. Sizing the hit area to this band.
    /// X taps (including gaps) still resolve to the nearest bar in `handleTap`.
    @ViewBuilder
    private func tapTarget(frame: CGRect, proxy: ChartProxy) -> some View {
        if let y = proxy.position(forY: viewModel.maxAmount) {
            let topY = frame.minY + y
            let bottomY = frame.maxY
            let bandHeight = max(0, bottomY - topY)
            if bandHeight > 0 {
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .frame(width: frame.width, height: bandHeight)
                    .position(x: frame.midX, y: topY + bandHeight / 2)
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                handleTap(at: value.location,
                                          plotFrame: frame,
                                          proxy: proxy)
                            }
                    )
            }
        }
    }

    /// Day capsule shown below the plot for the selected bar's day, centered
    /// on that day's group via `dayCenterUnit`.
    @ViewBuilder
    private func selectedLabel(frame: CGRect, proxy: ChartProxy) -> some View {
        if let selected = selectedBar,
           let dayIndex = viewModel.days.firstIndex(where: { $0.day == selected.day }),
           let xPos = proxy.position(forX: dayCenterUnit(dayIndex: dayIndex)) {
            Text("\(selected.day) sep")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(Color("primaryText"))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color("background").opacity(0.9)))
                .position(x: frame.origin.x + xPos, y: frame.maxY + 16)
                .allowsHitTesting(false)
                .transition(.opacity)
        }
    }

    // MARK: - Tap handling

    /// Maps a tap to the nearest individual transaction in unit space, so same-day siblings are separately selectable.
    /// Tapping the already-selected bar deselects it.
    private func handleTap(at location: CGPoint,
                           plotFrame: CGRect,
                           proxy: ChartProxy) {
        let xInPlot = location.x - plotFrame.origin.x
        guard let tappedX: Double = proxy.value(atX: xInPlot) else { return }

        var nearest: SelectedBar?
        var nearestDistance = Double.infinity
        for (index, day) in viewModel.days.enumerated() {
            for tx in day.transactions {
                let distance = abs(unitPosition(dayIndex: index, txIndex: tx.indexInDay) - tappedX)
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearest = SelectedBar(day: day.day, indexInDay: tx.indexInDay)
                }
            }
        }

        withAnimation(.easeInOut(duration: 0.15)) {
            selectedBar = (selectedBar == nearest) ? nil : nearest
        }
    }

    /// Per-transaction dimming: the selected bar stays full opacity, every
    /// other bar dims. With no selection everything is full opacity.
    private func dimmedOpacity(for day: DayGroup, tx: MonthlyTransaction) -> Double {
        guard let selected = selectedBar else { return 1.0 }
        return (selected.day == day.day && selected.indexInDay == tx.indexInDay) ? 1.0 : 0.45
    }
}

/// Horizontal dashed reference-line shape used for the max-amount line.
private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
