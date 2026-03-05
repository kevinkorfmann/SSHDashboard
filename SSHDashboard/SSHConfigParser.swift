import Foundation

struct SSHHost {
    let name: String
    let hostName: String
    let user: String?

    var displayName: String { name }
}

struct SSHConfigParser {
    static func parse() -> [SSHHost] {
        let configPath = NSString("~/.ssh/config").expandingTildeInPath
        guard let content = try? String(contentsOfFile: configPath, encoding: .utf8) else {
            return []
        }

        var hosts: [SSHHost] = []
        var currentName: String?
        var currentHostName: String?
        var currentUser: String?

        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let parts = trimmed.split(separator: " ", maxSplits: 1).map(String.init)
            guard parts.count == 2 else {
                if trimmed.isEmpty, let name = currentName {
                    // End of a host block
                    let hostName = currentHostName ?? name
                    // Skip wildcard and github entries
                    if !name.contains("*") && !name.contains("github") {
                        hosts.append(SSHHost(name: name, hostName: hostName, user: currentUser))
                    }
                    currentName = nil
                    currentHostName = nil
                    currentUser = nil
                }
                continue
            }

            let key = parts[0].lowercased()
            let value = parts[1]

            switch key {
            case "host":
                // Save previous host if exists
                if let name = currentName {
                    let hostName = currentHostName ?? name
                    if !name.contains("*") && !name.contains("github") {
                        hosts.append(SSHHost(name: name, hostName: hostName, user: currentUser))
                    }
                }
                currentName = value
                currentHostName = nil
                currentUser = nil
            case "hostname":
                currentHostName = value
            case "user":
                currentUser = value
            default:
                break
            }
        }

        // Don't forget the last host
        if let name = currentName {
            let hostName = currentHostName ?? name
            if !name.contains("*") && !name.contains("github") {
                hosts.append(SSHHost(name: name, hostName: hostName, user: currentUser))
            }
        }

        return hosts
    }
}
