import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            Text("Pith Voice")
        }
    }
}

#Preview {
    RootView()
}
