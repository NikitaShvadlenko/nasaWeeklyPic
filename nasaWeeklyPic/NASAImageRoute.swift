//
//  NASAImageRoute.swift
//  nasaWeeklyPic
//
//  Created by Nikita Shvad on 24.08.2021.
//

import Foundation
import Moya

enum NASAImageRoute {
    case image(url: URL)
}

extension NASAImageRoute: TargetType {
    var baseURL: URL {
        switch self {
        case let .image(url):
            return url
        }
    }
    
    var path: String {
        ""
    }
    
    var method: Moya.Method {
        .get
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        .requestPlain
    }
    
    var headers: [String : String]? {
        nil
    }
    
    
}
