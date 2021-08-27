//
//  OpenNasaRoute.swift
//  nasaWeeklyPic
//
//  Created by Nikita Shvad on 24.08.2021.
//
import Foundation
import Moya

enum OpenNasaRoute {
    case apod(startDateString: String, endDateString: String)
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
        case let .apod(startDateString, endDateString):
            let parameters: [String: Any] = [
                "api_key": "DEMO_KEY",
                "start_date": startDateString,
                "end_date": endDateString
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    var headers: [String : String]? {
        return nil
    }
}
