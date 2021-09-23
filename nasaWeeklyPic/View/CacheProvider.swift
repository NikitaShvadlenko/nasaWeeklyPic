//
//  CacheProvider.swift
//  nasaWeeklyPic
//
//  Created by Nikita Shvad on 24.09.2021.
//

import UIKit

protocol CacheProviderProtocol {
    //Почему дата может быть нил в теории?
    func retrieve(key: String) -> Data?
    func save(key: String, value: Data)
}

class CacheProvider {
    private var values = [String: Data]()
    //Создал новую очередь - с таким-то названием, concurrent - в любой момент что угодно делает, но требует больше памяти на такое (позволяет несколько threads юзать разом).
    private let queue = DispatchQueue(label: "nasaWeeklyPic.cacheQueue", qos: .userInitiated, attributes: .concurrent)
}

extension CacheProvider: CacheProviderProtocol {
    func retrieve(key: String) -> Data? {
        //Sync - чтобы по очереди показывало картинки, 6543. А не несколько разом?
        queue.sync {
            return values[key]
        }
    }
    
    func save(key: String, value: Data) {
        queue.async(flags: .barrier) { [weak self] in
            self?.values[key] = value
        }
    }
}

