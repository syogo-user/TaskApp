//
//  Task.swift
//  taskapp
//
//  Created by 小野寺祥吾 on 2020/01/04.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import RealmSwift
class Task: Object {
    //管理用ID。プライマリーキー
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    //id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
