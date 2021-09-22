//
//  CacheProvider.swift
//  nasaWeeklyPic
//
//  Created by Nikita Shvad on 23.09.2021.
//

import UIKit
/* 111Вообще есть такая штука как NSCache, но пока давай без нее попробуем.
1) Такая идея, создаешь класс CacheProvider,
 2) В классе CacheProvider будет приватное проперти типа Dictionary<String, Data> (private var cache: [String: Data])
 и два метода - получить из кэша и добавить
 2) создаешь его экземпляр во вью контроллере.
 3) При конфигурации ячейки передаешь этот экземпляр в каждую ячейку, и внутри ячейки перед загрузкой изображения сначала проверяешь есть ли он в кэше, и если есть, то берешь из кэша, если нет, то загружаешь изображение и сохраняешь в кэш. Подсказка, сохраняй Data изображения.


 а потом посмотрим твой код

 А еще объясни, почему я говорю именно class CacheProvider сделать, а не struct*/

class CacheProvider {
    
     var cache: [URL: UIImage] = [:]
    
    public func addToCache(picUrl: URL ,data:UIImage) {
        cache[picUrl] = data
    }
    
    public func getFromCache(){
        
    }
    
}
