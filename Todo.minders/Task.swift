//
//  Task.swift
//  Todo.minders
//
//  Created by Victor Kenzo Nawa on 2/13/18.
//  Copyright © 2018 Victor Kenzo Nawa. All rights reserved.
//

import UIKit
import RealmSwift

class Task: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var shouldAct = false
    @objc dynamic var noDate = false
    @objc dynamic var notificationTime = Date()
    
}

