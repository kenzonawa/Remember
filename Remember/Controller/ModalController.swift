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
        button.setTitle("Add Task", for: .normal)
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        return button
    }()
    
    let row: UIView = {
        let row = UIView()
        let top = UIView()
        let bottom = UIView()
        let color = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        row.addSubview(top)
        row.addSubview(bottom)
        row.addConstraintsWithFormat(format: "H:|[v0]|", views: top)
        row.addConstraintsWithFormat(format: "H:|[v0]|", views: bottom)
        row.addConstraintsWithFormat(format: "V:|[v0(1)]", views: top)
        row.addConstraintsWithFormat(format: "V:[v0(1)]|", views: bottom)
        
        top.backgroundColor = color
        bottom.backgroundColor = color
        
        return row
    }()
    
    let noDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Set Reminder"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    let toggle = UISwitch()
    
    let noDateButton: SecondaryButton = {
        let button = SecondaryButton()
        button.setTitle("No Date", for: .normal)
        button.addTarget(self, action: #selector(addTodo), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNewTask()
        
        datePicker.minimumDate = Date(timeIntervalSinceNow: 60)
        
        setupRow()

        formView.addSubview(datePicker)
        formView.addSubview(row)
        formView.addSubview(addButton)
        
//        formView.addSubview(noDateButton)
//        formView.addConstraintsWithFormat(format: "H:|-24-[v0(132)]", views: noDateButton)
//        formView.addConstraintsWithFormat(format: "V:[v0(48)]-24-|", views: noDateButton)
        
        formView.addConstraintsWithFormat(format: "H:|[v0]|", views: datePicker)
        formView.addConstraintsWithFormat(format: "H:|[v0]|", views: row)
        
        formView.addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: addButton)
        formView.addConstraintsWithFormat(format: "V:|-[v0]-[v1(64)]", views: datePicker,row)
        
        formView.addConstraintsWithFormat(format: "V:[v0(52)]-24-|", views: addButton)
        
        view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        
        view.addSubview(backgroundView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: backgroundView)
        view.addConstraintsWithFormat(format: "V:|[v0]|", views: backgroundView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        backgroundView.addGestureRecognizer(gesture)
        
        view.addSubview(formView)
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        
        print(width)
        
        if width < 360 {
            view.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: formView)
        } else {
        view.addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: formView)
        }
        view.addConstraintsWithFormat(format: "V:[v0(400)]", views: formView)
        let YConstraint = formView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        NSLayoutConstraint.activate([YConstraint])
        
        
        UNUserNotificationCenter.current().getNotificationSettings { (thing) in
            if thing.authorizationStatus.rawValue == 1 {
                
                let alertController = UIAlertController (title: "Notifications Disabled", message: "To receive reminders, enable notifications on the Settings page", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
                alertController.addAction(settingsAction)
                
                
                self.present(alertController, animated: true, completion: nil)
                
            } else{
                
            }
            
        }
        
    }
    
    func setupRow() {
        
        toggle.setOn(true, animated: false)
        toggle.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        
        row.addSubview(noDateLabel)
        row.addSubview(toggle)
        
        row.addConstraintsWithFormat(format: "H:|-24-[v0]", views: noDateLabel)
        row.addConstraintsWithFormat(format: "H:[v0]-24-|", views: toggle)
        noDateLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor).isActive = true
        toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor).isActive = true
        
    }
    
    @objc func switchToggled () {
        
        if toggle.isOn {
            datePicker.isEnabled = true
        } else {
            datePicker.isEnabled = false
        }
        
        
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
        
        DataManager.shared.mainController.isEmpty = false
        DataManager.shared.mainController.getData()
        DataManager.shared.mainController.collectionView?.reloadData()
        DataManager.shared.mainController.clearTextField()
        dismissModal()
    }
    
    @objc func addTask(){
        
        let timeComponents = Calendar.current.dateComponents([.year, .month, .day , .hour, .minute], from: datePicker.date)
        
        var components = DateComponents()
        components.year = timeComponents.year
        components.month = timeComponents.month
        components.day = timeComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.timeZone = .current
        
        let time = Calendar.current.date(from: components)!
        
        var task: Task
        
        let uuid = UUID().uuidString
        
        // If no task was tapped -> New Task
        if isNewTask {
            
            if toggle.isOn { // New Task & Reminder Date
                
                task = {
                    let newTask = Task()
                    newTask.name = taskText!
                    newTask.notificationTime = time
                    newTask.uuid = uuid
                    return newTask
                }()
                
            }
                
            else {  // New Task & No Date
            
                task = {
                    let newTask = Task()
                    newTask.name = taskText!
                    newTask.noDate = true
                    return newTask
                }()
                
            }
            
            try! realm.write {
                realm.add(task)
            }
            
        }
        
        // Selected a Task
        else {
            
            if toggle.isOn { // Old Task & Reminder Date
                
                task = currentTask!
                
                try! realm.write {
                    task.notificationTime = time
                    task.shouldAct = false
                    task.noDate = false
                    if task.uuid == "" {
                        task.uuid = uuid
                    }
                }
                print(task)
                
            }
            
            else { // Old Task & No Date - No sense option
                
                task = currentTask!
                try! realm.write {
                    task.notificationTime = Date()
                    task.shouldAct = false
                    task.noDate = true
                }
                
            }
        }
        
        
        
//        let timeInterval = time.timeIntervalSinceNow
        
        scheduleNotification(task: task, completion: {success in
            if success{
                print("Successfully scheduled notification")
            } else {
                //print("Error schedulign notification")
            }
        })
        
        DataManager.shared.mainController.isEmpty = false
        DataManager.shared.mainController.getData()
        DataManager.shared.mainController.collectionView?.reloadData()
        DataManager.shared.mainController.clearTextField()
        dismissModal()
    }
    
    func scheduleNotification(task: Task, completion: @escaping (_ Success: Bool) -> ()) {
        
        let notif = UNMutableNotificationContent()
        
        notif.title = "Reminder"
        notif.body = task.name
        notif.sound = UNNotificationSound.default()
        
        let components = datePicker.calendar.dateComponents([.day, .hour, .minute], from: datePicker.date)
        
        var date = DateComponents()
        date.day = components.day
        date.hour = components.hour
        date.minute = components.minute
        let notifTrigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.uuid , content: notif, trigger: notifTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("error?")
            } else {
                print("New Notification Scheduling Success")
            }
        })
        
//        let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
    
//        let request = UNNotificationRequest(identifier: task.uuid, content: notif, trigger: notifTrigger)
//
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
//            if error != nil {
//                completion(false)
//            } else {
//                completion(true)
//            }
//        })
        
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
