import Foundation
public struct ios_collector {
    public private(set) var text = "Hello, World!"

    
    
    var userID: String;
    var visitorID: String;
    var type = "ecommerce";
    var listingUrl = "https://collect.enhencer.com/api/listings/";
    var productUrl = "https://collect.enhencer.com/api/products/";
    var purchaseUrl = "https://collect.enhencer.com/api/purchases/";
    var customerUrl = "https://collect.enhencer.com/api/customers/";
    var nav = 2;
    

    public init(token: String) {
        self.userID = token;
        self.visitorID = "";
        
        if let v = UserDefaults.standard.string(forKey: "enh_visitor_session") {
            self.visitorID = v;
        } else {
            let v = self.generateVisitorID();
            self.visitorID = v;
            UserDefaults.standard.set(v, forKey: "enh_visitor_session")
        }

    }
    
    private func generateVisitorID() -> String {
          let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          return String((0..<8).map{ _ in letters.randomElement()! })
    }
    
    public func listingPageView(category: String) -> Bool {
        let url = URL(string: self.listingUrl)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "type": self.type,
            "visitorID": self.visitorID,
            "productCategory1": category,
            "productCategory2": "",
            "deviceType": "iOS",
            //source: self.getCookie("enh_source") === null ? "" : self.getCookie("enh_source"),
            "userID": self.userID,
            "id": self.visitorID
        ]
        request.httpBody = parameters.percentEncoded()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {                                                               // check for fundamental networking error
                print("error", error ?? URLError(.badServerResponse))
                return
            }
            
            guard (200 ... 300) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            print("response data \(data)")
            
            /*do {
                let responseObject = try JSONDecoder().decode(ResponseObject<Response>.self, from: data)
                print(responseObject)
            } catch {
                print(error) // parsing error
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                } else {
                    print("unable to parse response as string")
                }
            }*/
        }

        task.resume()
        return true
    }

    

}


extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

struct ResponseObject<T: Decodable>: Decodable {
    let form: T    // often the top level key is `data`, but in the case of https://httpbin.org, it echos the submission under the key `form`
}

struct Response: Decodable {
    let content: String
}
