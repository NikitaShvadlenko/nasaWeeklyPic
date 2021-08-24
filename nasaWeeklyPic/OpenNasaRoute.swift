//
//  OpenNasaRoute.swift
//  nasaWeeklyPic
//
//  Created by Nikita Shvad on 24.08.2021.
//
import Foundation
import Moya

enum OpenNasaRoute {
    case apod(count: Int)
}

extension OpenNasaRoute: TargetType {
    var baseURL: URL {
        URL(string: "https://api.nasa.gov/planetary/")!
    }
    
    var path: String {
        switch self {
        case .apod:
            return "apod"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .apod:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case let .apod(count):
            let parameters: [String: Any] = [
                "api_key": "DEMO_KEY",
                "count": count
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    var headers: [String : String]? {
        return nil
    }
}
