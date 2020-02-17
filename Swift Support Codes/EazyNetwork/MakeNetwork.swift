//
//  MakeNetwork.swift
//  EezyNetwork
//
//  Created by Shyngys Kuandyk on 1/30/20.
//  Copyright © 2020 Shyngys Kuandyk. All rights reserved.
//

import Foundation


public enum Networkstate:String {
    case success
    case failure
}

public enum HTTPTask {
    
    case request
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
    case requestParametersAndHeaders(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?,method:HTTPMethods)
    case requestFormURL(bodyParameters: Parameters?, additionHeaders: HTTPHeaders?, method: HTTPMethods)
    
}


public enum RequestType {
    case request
    case requestFormURL(bodyParameter:Parameters?,additionHeaders:HTTPHeaders?,method:HTTPMethods)
    case requestParametres(bodyParameters: Parameters?,
    bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?,method:HTTPMethods)
    case requestParametersAndHeaders(bodyParameters: Parameters?,
    bodyEncoding: ParameterEncoding,
    urlParameters: Parameters?,
    additionHeaders: HTTPHeaders?,method:HTTPMethods)
    
}


public enum Result<String>{
    case success(String)
    case failure(String)
    case warning(String)
}

public enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}



public class Networking {
    
    public init(baseURL:URL) {
        self.baseURL = baseURL
    }
    
 
    
  public var task: URLSessionTask?
   public var baseURL : URL
  public var timeRequest : Double?
    
    public func makeNetworking<Model:Codable>(requestType:HTTPTask,path:String,module:Model.Type, onCompletion:@escaping(Model?,_ error:Result<String>)->())->() {
            let session = URLSession.shared
        
                   do {
                    let request = try self.makeRequest(requestType, path: path)
                       NetworkLogger.log(request: request)
                    task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                        
                        guard let responseData = response as? HTTPURLResponse else {
                            return onCompletion(nil,Result.failure("Bad Gateway"))
                            
                        }
                        
                        let result = self.handleNetworkResponse(responseData)
                        
                        switch result {
                        case .success(let state),.warning(let state):
                            
                            guard let responseData = data else {return}
                                                  do {
                                                    let apiResponse = try JSONDecoder().decode(module, from: responseData)
                                                    onCompletion(apiResponse,Result.success(state))
                                                  }
                                                  catch {
                                                    onCompletion(nil,Result.failure(state))
                                                  }
                        case .failure(let error):
                            onCompletion(nil,Result.failure(error))
                        }
                    })
                   
                   }
                   catch {
                    onCompletion(nil, Result.failure("Unknown Error"))
                   }
                   self.task?.resume()
        }
    
  public func makeRequest(_ requestType:HTTPTask,path:String) throws -> URLRequest {
    var request = URLRequest(url: baseURL.appendingPathComponent(path), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeRequest ?? 10.0)
        
        do {
        switch requestType {
        case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        case .requestFormURL(let bodyParameter,let additionHeaders,let method):
            request.httpMethod = method.rawValue

             addAdditionalHeaders(["Content-Type": "application/x-www-form-urlencoded"], request: &request)
                addAdditionalHeaders(additionHeaders, request: &request)
                let bodyText = buildBodyForFormUrl(bodyParameter)
                request.httpBody = bodyText
            
        case .requestParametersAndHeaders(let bodyParameters,let bodyEncoding,let urlParameters,let additionHeaders, let method):
            request.httpMethod = method.rawValue

            try self.configureParameters(bodyParameters: bodyParameters, bodyEncoding: bodyEncoding, urlParameters: urlParameters, method: method, request: &request)
            self.addAdditionalHeaders(additionHeaders, request: &request)
        case .requestParameters(let bodyParameters,let bodyEncoding, let urlParameters):
            
            try self.configureParameters(bodyParameters: bodyParameters,
                     bodyEncoding: bodyEncoding,
                     urlParameters: urlParameters, method: .get,
                     request: &request)
            }
            
            return request
        } catch {
            throw error
            }

       
    }
    
    
    
    public func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         method:HTTPMethods?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    public func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    public func buildBodyForFormUrl(_ bodyParameters: Parameters?) -> Data? {
        
        guard let parameters = bodyParameters else { return nil }
        
        var bodyText = ""
        for keyAndValue in parameters {
            bodyText += "\(bodyText == "" ? "" : "&")\(keyAndValue.key)=\(keyAndValue.value)"
        }
        
        let bodyData = bodyText.data(using:String.Encoding.ascii, allowLossyConversion: false)
        return bodyData
        
    }
    
    
    
    func cancel() {
        self.task?.cancel()
    }
    
    public enum state {
        case error
        case success
    }
    
    
    public func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        
        switch response.statusCode {
        case 100: return .success("Continue")
        case 101: return .success("Switching Protocols")
        case 102: return .success("Processing")
        case 200: return .success("OK")
        case 201: return .success("Created")
        case 202: return .success("Accepted")
        case 203: return .success("Non-Authoritative Information")
        case 204: return .success("No Content")
        case 205: return .success("Reset Content")
        case 206: return .success("Partial Content")
        case 207: return .success("Multi-Status")
        case 208: return .success("Already Reported")
        case 226: return .success("IM Used")
        case 209...225: return .success("Success")
        case 225...299: return .success("Success")
        case 309...399: return .warning("Redirection")
        case 300: return .warning("Multiple Choices")
        case 301: return .warning("Moved Permanently")
        case 302: return .warning("Moved Temporarily")
        case 303: return .warning("See Other")
        case 304: return .warning("Not Modified")
        case 305: return .warning("Use Proxy")
        case 306: return .warning("Reserved")
        case 307: return .warning("Temporary Redirect")
        case 308: return .warning("Permanent Redirect")
        case 400: return .failure("Bad Request")
        case 401: return .failure("Unauthorized")
        case 402: return .failure("Payment Required")
        case 403: return .failure("Forbidden")
        case 404: return .failure("Not found")
        case 405: return .failure("Method Not Allowed")
        case 406: return .failure("Not Acceptable")
        case 410: return .failure("Gone")
        case 411: return .failure("Length Required")
        case 412: return .failure("Precondition Failed")
        case 413: return .failure("Payload Too Large")
        case 414: return .failure("URI Too Long")
        case 415: return .failure("Unsupported Media Type")
        case 416: return .failure("Range Not Satisfiable")
        case 417: return .failure("Expectation Failed")
        case 418: return .failure("I’m a teapot")
        case 419: return .failure("Authentication Timeout (not in RFC 2616)")
        case 421: return .failure("Misdirected Request")
        case 422: return .failure("Unprocessable Entity")
        case 423: return .failure("Locked")
        case 424: return .failure("Failed Dependency")
        case 426: return .failure("Upgrade Required")
        case 428: return .failure("Precondition Required")
        case 429: return .failure("Too Many Requests")
        case 431: return .failure("Request Header Fields Too Large")
        case 449: return .failure("Retry With")
        case 451: return .failure("Unavailable For Legal Reasons")
        case 499: return .failure("Client Closed Request")
        case 407...409,420,430,431...448,450,452...498: return .failure("Error")
        case 500: return .failure("Internal Server Error")
            case 501: return .failure("Not Implemented")
            case 502: return .failure("Bad Gateway")
            case 503: return .failure("Service Unavailable")
            case 504: return .failure("Gateway Timeout")
            case 505: return .failure("HTTP Version Not Supported")
            case 506: return .failure("Variant Also Negotiates")
            case 507: return .failure("Insufficient Storage")
            case 508: return .failure("Loop Detected")
            case 509: return .failure("Bandwidth Limit Exceeded")
            case 510: return .failure("Not Extended")
            case 511: return .failure("Network Authentication Required")
        case 512...519: return .failure("Internal server Error")
            case 520: return .failure("Unknown Error")
                case 521: return .failure("Web Server Is Down")
                case 522: return .failure("Connection Timed Out")
                case 523: return .failure("Origin Is Unreachable")
                case 524: return .failure("A Timeout Occurred")
                case 525: return .failure("SSL Handshake Failed")
            case 526: return .failure("Invalid SSL Certificate")


        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
    
}
