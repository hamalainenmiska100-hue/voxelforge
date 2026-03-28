import SwiftUI

struct MainMenuView: View {
    @State private var startGame = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.44, green: 0.71, blue: 0.98), Color(red: 0.16, green: 0.27, blue: 0.48)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 18) {
                    Spacer()

                    VStack(spacing: 10) {
                        Text("VoxelForge")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(radius: 8)
                        Text("Natiivi iOS voxel sandbox. chunkit, Metal-renderöinti ja oma atlas-textuuri.")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: 500)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    VStack(spacing: 14) {
                        NavigationLink(isActive: $startGame) {
                            GameView()
                        } label: { EmptyView() }

                        Button(action: { startGame = true }) {
                            HStack {
                                Image(systemName: "globe.europe.africa.fill")
                                Text("Luo maailma")
                            }
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(.black)
                            .frame(maxWidth: 380)
                            .padding(.vertical, 18)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        Text("Buildi on tarkoituksella pidetty yhdessä app-targetissa ilman kansiohelvettiä.")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 56)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
