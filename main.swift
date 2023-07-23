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
  let aSt = GetHTML(fName: "select.html")

  var sBig: String = ""
  for s in aSt {
    print(s)
    sBig+="\r\n"+s
  }

  let httpResponse: String = """
    HTTP/1.1 200 OK
    server: sub-server
    content-length: \(sBig.count)

    \(sBig)
    """


  httpResponse.withCString { bytes in
    send(client, bytes, Int(strlen(bytes)), 0)
    close(client)
  }
} while sock > -1

func GetHTML(fName: String) -> [String] {

  let path = FileManager.default.currentDirectoryPath + "/" + fName
  print("Reading file..." + path)

  var text = [String]()
  let file = freopen(path, "r", stdin)
  while let line = readLine() {
    print(line)
    text.append(line)
  }
  fclose(file)

  print(text)
  return text
}
