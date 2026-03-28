import SwiftUI
import MetalKit

struct MetalGameView: UIViewRepresentable {
    @ObservedObject var gameState: GameState

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero)
        view.isPaused = false
        view.enableSetNeedsDisplay = false
        view.preferredFramesPerSecond = 60
        context.coordinator.renderer = Renderer(view: view, gameState: gameState)
        view.delegate = context.coordinator.renderer
        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {}

    final class Coordinator {
        var renderer: Renderer?
    }
}

struct GameView: View {
    @StateObject private var gameState = GameState()
    @Environment(\.dismiss) private var dismiss
    @State private var move = CGSize.zero
    @State private var look = CGSize.zero

    var body: some View {
        ZStack {
            MetalGameView(gameState: gameState)
                .ignoresSafeArea()
                .overlay(alignment: .center) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white.opacity(0.85))
                        .shadow(radius: 2)
                }

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Label("Valikko", systemImage: "chevron.left")
                            .font(.headline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                    }

                    Spacer()

                    HStack(spacing: 10) {
                        Button("Riko") { gameState.breakBlock() }
                        Button("Aseta") { gameState.placeBlock() }
                        Button("Hyppy") { gameState.player.jump() }
                    }
                    .buttonStyle(HUDButtonStyle())
                }
                .padding()

                Spacer()

                HStack(alignment: .bottom) {
                    VirtualPad(title: "Liike", offset: $move) { vector in
                        gameState.player.moveInput = SIMD2<Float>(Float(vector.width / 45), Float(-vector.height / 45))
                    }

                    Spacer()

                    VirtualPad(title: "Katse", offset: $look) { vector in
                        gameState.player.lookInput = SIMD2<Float>(Float(vector.width / 35), Float(vector.height / 35))
                    }
                }
                .padding(24)
            }
        }
        .statusBarHidden(true)
    }
}

struct VirtualPad: View {
    let title: String
    @Binding var offset: CGSize
    let onChange: (CGSize) -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 134, height: 134)
            Circle()
                .fill(.white.opacity(0.25))
                .frame(width: 58, height: 58)
                .offset(offset)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.8))
                .offset(y: 72)
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let maxRadius: CGFloat = 38
                    let dx = value.translation.width
                    let dy = value.translation.height
                    let length = max(1, sqrt(dx * dx + dy * dy))
                    if length > maxRadius {
                        offset = CGSize(width: dx / length * maxRadius, height: dy / length * maxRadius)
                    } else {
                        offset = CGSize(width: dx, height: dy)
                    }
                    onChange(offset)
                }
                .onEnded { _ in
                    offset = .zero
                    onChange(.zero)
                }
        )
    }
}

struct HUDButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}
