//
//  CacheProvider.swift
//  nasaWeeklyPic
//
//  Created by Vladislav Lisianskii on 23.09.2021.
//

import Foundation

protocol CacheProviderProtocol: AnyObject {
    func retrieve(key: URL) -> Data?
    func save(key: URL, value: Data)
}

class CacheProvider {
    private var values = [URL: Data]()
    
    private let queue = DispatchQueue(label: "nasaWeeklyPic.cacheQueue", qos: .userInitiated, attributes: .concurrent)
}

extension CacheProvider: CacheProviderProtocol {
    func retrieve(key: URL) -> Data? {
        queue.sync {
            return values[key]
        }
    }
    
    func save(key: URL, value: Data) {
        queue.async(flags: .barrier) { [weak self] in
            self?.values[key] = value
        }
    }
}
