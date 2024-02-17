# swift-network-dns

Swift DNS

```swift
import Foundation
import NetworkDNS

let queue = DispatchQueue(label: "swift-network-dns", qos: .utility)
let service = DNSService(host: "8.8.8.8", queue: queue)

let response = try await service.send(.question(domain: "google.com", type: .a))
response.answers.forEach { record in
    print("IPv4: \(record.ipv4 ?? "nil"), \(record.name)")
}
```
