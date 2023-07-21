#if os(Linux)

import Glibc
let zero = UInt8(0)
let transportLayerType = SOCK_STREAM.rawValue // TCP

#else

import Darwin.C
import Foundation
let zero = Int8(0)
let transportLayerType = SOCK_STREAM // TCP

#endif

let internetLayerProtocol = AF_INET // IPv4
let sock = socket(internetLayerProtocol, Int32(transportLayerType), 0)
let portNumber = UInt16(4000)
let socklen = UInt8(socklen_t(MemoryLayout<sockaddr_in>.size))
var serveraddr = sockaddr_in()
serveraddr.sin_family = sa_family_t(AF_INET)
serveraddr.sin_port = in_port_t((portNumber << 8) + (portNumber >> 8))
serveraddr.sin_addr = in_addr(s_addr: in_addr_t(0))
serveraddr.sin_zero = (zero, zero, zero, zero, zero, zero, zero, zero)
withUnsafePointer(to: &serveraddr) { sockaddrInPtr in
  let sockaddrPtr = UnsafeRawPointer(sockaddrInPtr).assumingMemoryBound(to: sockaddr.self)
  bind(sock, sockaddrPtr, socklen_t(socklen))
}
listen(sock, 5)
print("Server listening on port \(portNumber)")
repeat {
  let client = accept(sock, nil, nil)
  let html = GetHTML(filename: "select.html")
  let httpResponse: String = """
    HTTP/1.1 200 OK
    server: simple-swift-server
    content-length: \(html.count)

    \(html)
    """
  httpResponse.withCString { bytes in
    send(client, bytes, Int(strlen(bytes)), 0)
    close(client)
  }
} while sock > -1

func GetHTML(filename: String) -> String {
  var text="12345"
  print("Reading file...")

  let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  let fileURL = URL(fileURLWithPath: url.path + "/" + filename)
  print(fileURL)
  do {
  text = try String(contentsOf: fileURL, encoding: .utf8)
  } catch {}
  return text
}
