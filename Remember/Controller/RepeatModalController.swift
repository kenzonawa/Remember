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

class RepeatModalController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    enum PickerTag: Int {
        case Weekday
        case Monthday
    }
    
    var taskText: String?
    
    var currentTask: RepeatTask?
    
    var isNewTask: Bool = true
    
    var formHeight = NSLayoutConstraint()
    
    let realm = try! Realm()
    
    let items = ["Daily", "Weekly", "Monthly"]
    
    let values = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    
    let monthDays: Array<Int> = {
        var array = [Int]()
        for i in 1...31 {
            array.append(i)
        }
        return array
    }()
    
    var customSC: UISegmentedControl!
    
    var segmentIndex: Int! = 0
    
    var weekdayPicker: UIPickerView!
    
    var monthdayPicker: UIPickerView!
    
    let atLabel: UILabel = {
        let label = UILabel()
        label.text = "At"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    let weekdayLabel: UILabel = {
        let label = UILabel()
        label.text = "Every"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    let monthdayLabel1: UILabel = {
        let label = UILabel()
        label.text = "Every"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    let monthdayLabel2: UILabel = {
        let label = UILabel()
        label.text = "of the month"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    let formView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 4
        return view
    }()
    
    let datePicker = UIDatePicker()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNewTask()
        
        
        weekdayPicker = UIPickerView()
        weekdayPicker.delegate = self
        weekdayPicker.dataSource = self
        weekdayPicker.tag = PickerTag.Weekday.rawValue
        weekdayPicker.selectRow(3, inComponent: 0, animated: false)

        monthdayPicker = UIPickerView()
        monthdayPicker.delegate = self
        monthdayPicker.dataSource = self
        monthdayPicker.tag = PickerTag.Monthday.rawValue
        monthdayPicker.selectRow(4, inComponent: 0, animated: false)
        
        
        customSC = UISegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        let frame = view.frame
        customSC.frame = CGRect(x: frame.minX+10 , y: frame.minY+50, width: frame.width, height: 60)
        customSC.addTarget(self, action: #selector(changeSelector), for: .valueChanged)
        
        datePicker.datePickerMode = .time
        
        formView.addSubview(customSC)
        formView.addSubview(weekdayPicker)
        formView.addSubview(weekdayLabel)
        formView.addSubview(monthdayPicker)
        formView.addSubview(monthdayLabel2)
        formView.addSubview(monthdayLabel1)
        formView.addSubview(atLabel)
        formView.addSubview(datePicker)
        formView.addSubview(addButton)
        
        formView.addConstraintsWithFormat(format: "H:|-16-[v0]-16-[v1]-16-|", views: weekdayLabel, weekdayPicker)
        formView.addConstraintsWithFormat(format: "V:|-44-[v0]", views: weekdayPicker)
        formView.addConstraintsWithFormat(format: "V:|-140-[v0]", views: weekdayLabel)
        
        weekdayLabel.isHidden = true
        weekdayPicker.isHidden = true
        
        formView.addConstraintsWithFormat(format: "H:|-16-[v0(48)]-16-[v1]-16-[v2(108)]-16-|", views: monthdayLabel1,monthdayPicker,monthdayLabel2)
        formView.addConstraintsWithFormat(format: "V:|-44-[v0]", views: monthdayPicker)
        formView.addConstraintsWithFormat(format: "V:|-140-[v0]", views: monthdayLabel1)
        formView.addConstraintsWithFormat(format: "V:|-140-[v0]", views: monthdayLabel2)
        
        monthdayPicker.isHidden = true
        monthdayLabel1.isHidden = true
        monthdayLabel2.isHidden = true
        
        formView.addConstraintsWithFormat(format: "H:|-16-[v0(24)]-16-[v1]-16-|", views: atLabel, datePicker)
        formView.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: customSC)
        formView.addConstraintsWithFormat(format: "H:[v0(144)]-24-|", views: addButton)
        formView.addConstraintsWithFormat(format: "V:|-20-[v0]", views: customSC)
        formView.addConstraintsWithFormat(format: "V:[v0]-80-|", views: datePicker)
        formView.addConstraintsWithFormat(format: "V:[v0]-176-|", views: atLabel)
        formView.addConstraintsWithFormat(format: "V:[v0(48)]-24-|", views: addButton)
        
        view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        
        view.addSubview(backgroundView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: backgroundView)
        view.addConstraintsWithFormat(format: "V:|[v0]|", views: backgroundView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        backgroundView.addGestureRecognizer(gesture)
        
        view.addSubview(formView)
        view.addConstraintsWithFormat(format: "H:|-32-[v0]-32-|", views: formView)
        
        formHeight = formView.heightAnchor.constraint(equalToConstant: 348)
        
        let YConstraint = formView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        NSLayoutConstraint.activate([formHeight, YConstraint])
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let tag = pickerView.tag
        
        if tag == PickerTag.Weekday.rawValue {
            return values.count
        }
        if tag == PickerTag.Monthday.rawValue {
            return monthDays.count
        }
        return values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let tag = pickerView.tag
        
        if tag == PickerTag.Weekday.rawValue {
            return values[row]
        }
        if tag == PickerTag.Monthday.rawValue {
            return String(monthDays[row])
        }
        
        return values[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    
    @objc func changeSelector(sender: UISegmentedControl) {
        segmentIndex = sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 0:
            weekdayLabel.isHidden = true
            weekdayPicker.isHidden = true
            monthdayPicker.isHidden = true
            monthdayLabel1.isHidden = true
            monthdayLabel2.isHidden = true
            formHeight.constant = 348
            UIView.animate(withDuration: 0.5){
                self.formView.layoutIfNeeded()
            }
        case 1:
            weekdayLabel.isHidden = false
            weekdayPicker.isHidden = false
            weekdayPicker.alpha = 0
            weekdayLabel.alpha = 0
            monthdayPicker.isHidden = true
            monthdayLabel1.isHidden = true
            monthdayLabel2.isHidden = true
            formHeight.constant = 540
            UIView.animate(withDuration: 0.5, animations: {
                self.formView.layoutIfNeeded()
                self.weekdayPicker.alpha = 1
                self.weekdayLabel.alpha = 1
            }, completion: nil)
            
        case 2:
            weekdayLabel.isHidden = true
            weekdayPicker.isHidden = true
            monthdayPicker.isHidden = false
            monthdayLabel1.isHidden = false
            monthdayLabel2.isHidden = false
            monthdayPicker.alpha = 0
            monthdayLabel1.alpha = 0
            monthdayLabel2.alpha = 0
            formHeight.constant = 540
            UIView.animate(withDuration: 0.5, animations: {
                self.formView.layoutIfNeeded()
                self.monthdayPicker.alpha = 1
                self.monthdayLabel1.alpha = 1
                self.monthdayLabel2.alpha = 1
            }, completion: nil)
            
        default:
            print("Purple")
        }
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
    
    func scheduleDaily() {
        
        let notif = UNMutableNotificationContent()
        
        notif.title = "Reminder"
        notif.body = taskText!
        notif.sound = UNNotificationSound.default()
        
        let components = datePicker.calendar.dateComponents([.hour, .minute], from: datePicker.date)

        var date = DateComponents()
        date.hour = components.hour
        date.minute = components.minute
        let notifTrigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

        let request = UNNotificationRequest(identifier: taskText!, content: notif, trigger: notifTrigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("error?")
            } else {
                print("scheduled?")
            }
        })
    }
    
    func scheduleWeekly() {
        
        let notif = UNMutableNotificationContent()
        
        notif.title = "Reminder"
        notif.body = taskText!
        notif.sound = UNNotificationSound.default()
        
        let calendar = Calendar.current
        let nextWeekdays = weekdayPicker.selectedRow(inComponent: 0) + 1 /* adjustment for values array */
        
//        let currentDate = Date()
//        let weekday = DateComponents(weekday: nextWeekdays)
//        let nextOccurrence = calendar.nextDate(after: currentDate, matching: weekday, matchingPolicy: .nextTime)!
//        let weekComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: nextOccurrence)
        
        let timeComponents = datePicker.calendar.dateComponents([.hour, .minute], from: datePicker.date)
        
        
        var components = DateComponents()
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.weekday = nextWeekdays // sunday = 1 ... saturday = 7
        components.weekdayOrdinal = 10
        components.timeZone = .current
        
        let finalDate = calendar.date(from: components)!
        
        let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour,.minute,.second,], from: finalDate)

        print(triggerWeekly)
        
        let notifTrigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: false)
        
//        let request = UNNotificationRequest(identifier: taskText!, content: notif, trigger: notifTrigger)
//
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
//            if error != nil {
//                print("error?")
//            } else {
//                print("scheduled?")
//            }
//        })
    }
    
    @objc func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addTask(){
        
        let time = datePicker.date
        var task: RepeatTask
        var newFrequency = ""
        switch segmentIndex {
        case 0:
            newFrequency = "daily"
        case 1:
            newFrequency = "weekly"
        case 2:
            newFrequency = "monthly"
        default:
            print("daily")
        }
        
        // If no task was tapped -> New Task
        if isNewTask {
            
            task = {
                let newTask = RepeatTask()
                newTask.name = taskText!
                newTask.notificationTime = time
                newTask.frequency = newFrequency
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
                task.frequency = newFrequency
            }
            
        }
        
        
        switch segmentIndex {
        case 0:
            print("Daily")
            scheduleDaily()
            
            
        case 1:
            print("Weekly")
            scheduleWeekly()
            
        case 2:
            print("Monthly")
            
        default:
            print("Purple")
        }
        
        DataManager.shared.repeatController.getData()
        DataManager.shared.repeatController.collectionView?.reloadData()
        DataManager.shared.repeatController.clearTextField()
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
