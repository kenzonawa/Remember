//
//  ModalController.swift
//  Todo.minders
//
//  Created by Victor Kenzo Nawa on 2/12/18.
//  Copyright © 2018 Victor Kenzo Nawa. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ModalController: UIViewController {
    
    var taskText: String?
    
    var currentTask: Task?
    
    var isNewTask: Bool = true
    
    let realm = try! Realm()
    
    let formView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 4
        
        return view
    }()
    
    let datePicker = UIDatePicker()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("Add Task", for: .normal)
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        button.backgroundColor = UIColor(red: 64/255, green: 101/255, blue: 225/255, alpha: 1)
        button.layer.cornerRadius = 4
        return button
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let addButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle("Add Reminder", for: .normal)
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        return button
    }()
    
    let noDateButton: SecondaryButton = {
        let button = SecondaryButton()
        button.setTitle("No Date", for: .normal)
        button.addTarget(self, action: #selector(addTodo), for: .touchUpInside)
        return button
    }()
    
//    let toggleButton = UISwitch()
    
//    let reminderLabel: UILabel = {
//        let label = UILabel()
//        label.text = "No date"
//        return label
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNewTask()
        
        datePicker.minimumDate = Date(timeIntervalSinceNow: 120)
        
//        formView.addSubview(reminderLabel)
//        formView.addSubview(toggleButton)
        formView.addSubview(datePicker)
        formView.addSubview(noDateButton)
        formView.addSubview(addButton)
//        formView.addSubview(button)
        
//        formView.addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: reminderLabel)
//        formView.addConstraintsWithFormat(format: "V:|-20-[v0]", views: reminderLabel)
        formView.addConstraintsWithFormat(format: "H:|[v0]|", views: datePicker)
        formView.addConstraintsWithFormat(format: "H:|-24-[v0(132)]", views: noDateButton)
        formView.addConstraintsWithFormat(format: "H:[v0(144)]-24-|", views: addButton)
//        formView.addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: button)
        formView.addConstraintsWithFormat(format: "V:|-20-[v0]", views: datePicker)
        formView.addConstraintsWithFormat(format: "V:[v0(48)]-24-|", views: noDateButton)
        formView.addConstraintsWithFormat(format: "V:[v0(48)]-24-|", views: addButton)
        
        view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        
        view.addSubview(backgroundView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: backgroundView)
        view.addConstraintsWithFormat(format: "V:|[v0]|", views: backgroundView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        backgroundView.addGestureRecognizer(gesture)
        
        view.addSubview(formView)
        view.addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: formView)
        view.addConstraintsWithFormat(format: "V:[v0(332)]", views: formView)
        let YConstraint = formView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        NSLayoutConstraint.activate([YConstraint])
        
    }
    
    func scheduleNotification(taskName: String, inSeconds: TimeInterval, completion: @escaping (_ Success: Bool) -> ()) {
        
        let notif = UNMutableNotificationContent()
        
        notif.title = "Reminder"
        notif.body = taskName
        notif.sound = UNNotificationSound.default()
        
        let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: taskName, content: notif, trigger: notifTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        })
        
    }
    
    @objc func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addTodo(){
        
        var task: Task
        
        // If no task was tapped -> New Task
        if isNewTask {
            
            task = {
                let newTask = Task()
                newTask.name = taskText!
                newTask.noDate = true
                return newTask
            }()
            try! realm.write {
                realm.add(task)
            }
            
        } else {
            
            task = currentTask!
            
            try! realm.write {
                task.notificationTime = Date()
                task.shouldAct = false
                task.noDate = true
            }
            
        }
        
        DataManager.shared.mainController.getData()
        DataManager.shared.mainController.collectionView?.reloadData()
        DataManager.shared.mainController.clearTextField()
        dismissModal()
    }
    
    @objc func addTask(){
        
        let time = datePicker.date
        
        var task: Task
        
        // If no task was tapped -> New Task
        if isNewTask {
            
            task = {
                let newTask = Task()
                newTask.name = taskText!
                newTask.notificationTime = time
                return newTask
            }()
            try! realm.write {
                realm.add(task)
            }
            
        } else {
            print("WTF")
            task = currentTask!
            try! realm.write {
                task.notificationTime = time
                task.shouldAct = false
                task.noDate = false
            }
            
        }
        
        
        
        let timeInterval = time.timeIntervalSinceNow
        
        scheduleNotification(taskName: task.name, inSeconds: timeInterval, completion: {success in
            if success{
                print("Successfully scheduled notification")
            } else {
                //print("Error schedulign notification")
            }
        })
        
        DataManager.shared.mainController.getData()
        DataManager.shared.mainController.collectionView?.reloadData()
        DataManager.shared.mainController.clearTextField()
        dismissModal()
    }
    
    func checkNewTask() {
        if currentTask == nil {
            isNewTask = true
        }
        else {
            isNewTask = false
        }
    }
    
    
}
