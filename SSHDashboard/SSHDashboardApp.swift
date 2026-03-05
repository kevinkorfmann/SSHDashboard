import SwiftUI

@main
struct SSHDashboardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .defaultSize(width: 0, height: 0)
    }
}

class ClickableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var sshHosts: [SSHHost] = []
    var widgetWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        // Close any default windows SwiftUI may have created
        for window in NSApp.windows {
            window.close()
        }

        sshHosts = SSHConfigParser.parse()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "apple.terminal", accessibilityDescription: "SSH Dashboard")
        }

        buildMenu()
        showWidget()
    }

    func showWidget() {
        let hostNames = sshHosts.map { host in
            WidgetHost(
                label: host.user != nil ? "\(host.user!)@\(host.displayName)" : host.displayName,
                host: host
            )
        }

        let widgetView = DesktopWidgetView(hosts: hostNames, onConnect: { [weak self] host in
            self?.connectToSSH(host)
        }, onRefresh: { [weak self] in
            self?.refresh()
            self?.updateWidget()
        })

        let hostingView = NSHostingView(rootView: widgetView)
        let fittingSize = hostingView.fittingSize

        let window = ClickableWindow(
            contentRect: NSRect(x: 0, y: 0, width: fittingSize.width, height: fittingSize.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .normal
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isMovableByWindowBackground = true
        window.hasShadow = false
        window.acceptsMouseMovedEvents = true
        window.ignoresMouseEvents = false

        // Position bottom-right of main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - fittingSize.width - 20
            let y = screenFrame.minY + 20
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        window.orderFront(nil)
        widgetWindow = window
    }

    func updateWidget() {
        sshHosts = SSHConfigParser.parse()
        widgetWindow?.close()
        widgetWindow = nil
        showWidget()
    }

    func buildMenu() {
        let menu = NSMenu()

        if sshHosts.isEmpty {
            menu.addItem(NSMenuItem(title: "No SSH hosts found", action: nil, keyEquivalent: ""))
        } else {
            for host in sshHosts {
                let label = host.user != nil ? "\(host.user!)@\(host.displayName)" : host.displayName
                let item = NSMenuItem(title: label, action: #selector(connectToHost(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = host
                menu.addItem(item)
            }
        }

        menu.addItem(NSMenuItem.separator())

        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refresh), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func connectToSSH(_ host: SSHHost) {
        let sshCommand = host.user != nil ? "ssh \(host.user!)@\(host.hostName)" : "ssh \(host.hostName)"

        let script = """
        tell application "Terminal"
            activate
            do script "\(sshCommand)"
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }

    @objc func connectToHost(_ sender: NSMenuItem) {
        guard let host = sender.representedObject as? SSHHost else { return }
        connectToSSH(host)
    }

    @objc func refresh() {
        sshHosts = SSHConfigParser.parse()
        buildMenu()
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}
