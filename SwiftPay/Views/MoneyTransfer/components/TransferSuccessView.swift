//
//  TransferSuccessView.swift
//  SwiftPay
//
//

import SwiftUI

struct TransferSuccessView: View {

    let amount: String
    var onFinished: () -> Void = {}

    @State private var ringExpand = false
    @State private var checkScale: CGFloat = 0.3
    @State private var checkOpacity = 0.0
    @State private var tickTrim: CGFloat = 0
    @State private var confettiGo = false
    @State private var contentOpacity = 0.0

    // Auto-dismiss after the animation plays through.
    private let dismissAfter: Double = 2.4

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            // MARK: Confetti layer
            ConfettiBurst(go: confettiGo)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // MARK: Checkmark with ripples
                ZStack {
                    // Ripple rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.green.opacity(0.35 - Double(i) * 0.1), lineWidth: 2)
                            .frame(width: 120, height: 120)
                            .scaleEffect(ringExpand ? 1.6 + Double(i) * 0.35 : 0.6)
                            .opacity(ringExpand ? 0 : 1)
                            .animation(
                                .easeOut(duration: 1.4).delay(Double(i) * 0.15),
                                value: ringExpand
                            )
                    }

                    // Solid glow disc
                    Circle()
                        .fill(Color.green.opacity(0.18))
                        .frame(width: 128, height: 128)
                        .scaleEffect(ringExpand ? 1 : 0.6)
                        .opacity(contentOpacity)

                    // Green badge
                    Circle()
                        .fill(Color.green)
                        .frame(width: 96, height: 96)
                        .scaleEffect(checkScale)
                        .opacity(checkOpacity)
                        .shadow(color: .green.opacity(0.5), radius: 24)

                    // Tick (draw-on via trim)
                    CheckTickShape()
                        .trim(from: 0, to: tickTrim)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
                        .frame(width: 44, height: 32)
                        .scaleEffect(checkScale)
                }
                .frame(height: 190)
                .padding(.top, 40)

                // MARK: Labels
                VStack(spacing: 6) {
                    Text("Payment successful")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("$")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                        Text(formattedAmount)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Text("to Olivia Carter")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .opacity(contentOpacity)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Staggered spring choreography
            withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
                checkScale = 1
                checkOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
                tickTrim = 1
                ringExpand = true
                confettiGo = true
            }
            withAnimation(.easeIn(duration: 0.4)) {
                contentOpacity = 1
            }
            // Hand off to details screen
            DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter) {
                onFinished()
            }
        }
    }

    private var formattedAmount: String {
        if let value = Double(amount), !amount.isEmpty {
            return value.formatted(.number.precision(.fractionLength(2)).grouping(.automatic))
        }
        return amount.isEmpty ? "0.00" : amount
    }
}

// MARK: - Tick shape

private struct CheckTickShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return p
    }
}

// MARK: - Confetti

private struct ConfettiBurst: View {
    let go: Bool

    // Fixed random seed per view instance so pieces don't reshuffle mid-flight.
    private let pieces: [ConfettiPiece] = (0..<70).map { _ in ConfettiPiece.random() }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: piece.isCircle ? 999 : 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.isCircle ? piece.size : piece.size * 0.6)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.32)
                        .rotationEffect(.degrees(go ? piece.spin : 0))
                        .offset(
                            x: go ? piece.dx * geo.size.width * 0.55 : 0,
                            y: go ? piece.dy * geo.size.height * 0.55 + 220 : 0
                        )
                        .opacity(go ? (piece.fade ? 0 : 1) : 1)
                        .animation(
                            .easeOut(duration: piece.duration).delay(piece.delay),
                            value: go
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let dx: CGFloat
    let dy: CGFloat
    let spin: Double
    let duration: Double
    let delay: Double
    let isCircle: Bool
    let fade: Bool

    static func random() -> ConfettiPiece {
        let colors: [Color] = [.green, .blue, .orange, .pink, .yellow, .white, .purple, .cyan]
        return ConfettiPiece(
            color: colors.randomElement() ?? .white,
            size: CGFloat.random(in: 5...10),
            dx: CGFloat.random(in: -1...1),
            dy: CGFloat.random(in: -1...1),
            spin: Double.random(in: 180...720),
            duration: Double.random(in: 1.2...1.9),
            delay: Double.random(in: 0...0.25),
            isCircle: Bool.random(),
            fade: Bool.random()
        )
    }
}

#Preview {
    TransferSuccessView(amount: "1156.84")
}
