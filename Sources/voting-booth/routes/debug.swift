import PerfectHTTP

func debugRoutes() -> Routes {
  var debugRoutes = Routes(baseUri: "/debug")

  debugRoutes.add(method: .get, uri: "/franchises") {
    request, response in

    response
      .setHeader(.contentType, value: "application/json")
      .appendBody(string: String(data: try! encoder.encode(Array(franchises.keys)), encoding: .utf8)!)
      .completed()
  }

  return debugRoutes
}
