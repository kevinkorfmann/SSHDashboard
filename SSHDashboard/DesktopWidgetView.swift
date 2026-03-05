import SwiftUI

struct WidgetHost: Identifiable {
    let id = UUID()
    let label: String
    let host: SSHHost
}

struct DesktopWidgetView: View {
    let hosts: [WidgetHost]
    let onConnect: (SSHHost) -> Void
    let onRefresh: () -> Void

    @State private var hoveredId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "apple.terminal")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.cyan)
                Text("SSH HOSTS")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.cyan)
                Spacer()
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)

            if hosts.isEmpty {
                Text("No hosts found")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            } else {
                ForEach(hosts) { entry in
                    Button(action: { onConnect(entry.host) }) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 6, height: 6)
                            Text(entry.label)
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(hoveredId == entry.id ? Color.white.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                    .onHover { isHovered in
                        hoveredId = isHovered ? entry.id : nil
                    }
                }
            }
        }
        .padding(14)
        .frame(minWidth: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        )
    }
}
