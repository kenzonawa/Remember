//
//  ViewController.swift
//  Todo.minders
//
//  Created by Victor Kenzo Nawa on 2/6/18.
//  Copyright © 2018 Victor Kenzo Nawa. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    var viewBottomConstraint = NSLayoutConstraint()
    
    let realm = try! Realm()
    
    var taskList: Results<Task>!
    var todoList: Results<Task>!
    
    var isEmpty: Bool = true
    
    var currentIndexPath: IndexPath?
    
    var notifiedIndexes = [Int]()
    
    var guide: UILayoutGuide!
    
    var buttonList: [Int]!
    
    let notificationDelegate = UYLNotificationDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        
        if (taskList.count > 0) || (todoList.count > 0) {
            isEmpty = false
        } else {
            isEmpty = true
        }
        
        let taskInput: UIView = HomeInput(superView: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeController.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(HomeController.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeController.didAddTask), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        collectionView!.collectionViewLayout = layout
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.showsVerticalScrollIndicator = false
        navigationItem.title = "Tasks"
        let attributes = [
            NSAttributedStringKey.kern: 1.0,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium)
            ] as [NSAttributedStringKey : Any]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
//        UINavigationBar.appearance().titleTextAttributes = attributes
        
        
//        navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
        
        collectionView?.backgroundColor = UIColor.white
        setupNav()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound], completionHandler:{ (granted,error) in
            if granted {
                print("Notification access granted")
            } else{
                print("Notification not granted")
            }
        })
        
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        collectionView?.register(TaskCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView?.register(NotifiedCell.self, forCellWithReuseIdentifier: "notiId")
        collectionView?.register(TodoCell.self, forCellWithReuseIdentifier: "todoId")
        collectionView?.register(EmptyStateCell.self, forCellWithReuseIdentifier: "emptyId")
        collectionView?.register(Header.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(Footer.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerId")
        
        view.addSubview(taskInput)
        
        // Pin the leading edge of myView to the margin's leading edge
        taskInput.translatesAutoresizingMaskIntoConstraints = false
        
        guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            self.view.bottomAnchor.constraintEqualToSystemSpacingBelow(guide.bottomAnchor, multiplier: 1.0)
            ])
        
        let leadingConstraint = taskInput.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = taskInput.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        viewBottomConstraint = taskInput.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0)
        let heightConstraint = taskInput.heightAnchor.constraint(equalToConstant: 80)
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, viewBottomConstraint, heightConstraint])

        let notifiedItems = (collectionView?.numberOfItems(inSection: 0))!
        if notifiedItems > 0 {
            for i in 0...(notifiedItems-1) {
                notifiedIndexes.append(i)
            }
        }
        DataManager.shared.mainController = self
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)  //if desired
        if textField.text! == "" {
            return true
        } else {
            
            let modalController = ModalController()
            modalController.taskText = textField.text
            let navController = UINavigationController(rootViewController: modalController)
            navController.isNavigationBarHidden = true
            navController.modalPresentationStyle = .overCurrentContext
            navController.modalTransitionStyle = .crossDissolve
            present(navController, animated: true, completion: nil)
            
        }
        return true
    }
    
    func showModalforTextInput(task: UITextField) {
        let modalController = UIViewController()
        navigationController?.pushViewController(modalController, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isEmpty {
            
            let image = UIImage(named: "emptystate")
            let message = "To start adding reminders, write a task below"
            let title = "No reminders"
            self.collectionView?.setEmptyMessage(image: image!, message: message, title: title)
            
        }
        else { self.collectionView?.restore() }
        
        if section == 0 {
            
            return taskList!.count
        }
        if section == 1 {
            return todoList!.count
        }
        
        return 0
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 1 {
            
            let task = todoList![indexPath.item]
                
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "todoId", for: indexPath) as! TodoCell
            cell.updateUI(taskName: task.name, time: task.notificationTime)
            return cell
            
        } else {
    
            let task = taskList![indexPath.item]
            
            if task.notificationTime <= Date() {
                try! realm.write {
                    task.shouldAct = true
                }
            }
            
            if task.shouldAct {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notiId", for: indexPath) as! NotifiedCell
                cell.updateUI(taskName: task.name, time: task.notificationTime)
                cell.primaryButton.addTarget(self, action: #selector(DoneTapped), for: .touchUpInside)
                cell.primaryButton.tag = indexPath.row
                cell.primaryButton.isUserInteractionEnabled = true
                
                cell.secondaryButton.addTarget(self, action: #selector(SnoozeTapped), for: .touchUpInside)
                cell.secondaryButton.tag = indexPath.row
                cell.secondaryButton.isUserInteractionEnabled = true
                
                return cell
                
            } else {
            
                let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TaskCell
                cell.updateUI(taskName: task.name, time: task.notificationTime)
                return cell
                
            }
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var task: Task
        if indexPath.section == 0 {
            task = taskList![indexPath.row]
        } else {
            task = todoList![indexPath.row]
        }
        
        let modalController = ModalController()
        modalController.currentTask = task
        let navController = UINavigationController(rootViewController: modalController)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true, completion: nil)
        collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 1 {

            return CGSize(width: view.frame.width, height: 86)
            
        } else {
            
            let task = taskList![indexPath.item]
        
            if task.notificationTime <= Date() {
                try! realm.write {
                    task.shouldAct = true
                }
            }
            if task.shouldAct {
                
                return CGSize(width: view.frame.width, height: 138)
                
            } else {
                
                return CGSize(width: view.frame.width, height: 86)
                
            }
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! Header
            header.active()
            if(indexPath.section == 0) {
                header.label.text = "Reminders"
                header.label.addCharactersSpacing(1.2)
            } else if(indexPath.section == 1) {
                header.label.text = "No Date"
                header.label.addCharactersSpacing(1.2)
                if(self.collectionView?.numberOfItems(inSection: 1) == 0) {
                    header.inactive()
                } 
            }
            
            return header
        
        case UICollectionElementKindSectionFooter:
            
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerId", for: indexPath)
            
        default:
            return UICollectionReusableView()
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
//        if section == 0{
//            return CGSize(width: 0, height: 0)
//        }
        
        if isEmpty {
            return CGSize(width: 0, height: 0)
        }
        
        return CGSize(width: view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if(section == 0) {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: view.frame.width, height: 72)
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print("works..")
        deleteTask(indexPathRow: indexPath.row, section: indexPath.section)
        print("works 2 ..")
        if !isEmpty {
            collectionView.deleteItems(at: [indexPath])
        }
        print("works 3 ..")
        
        collectionView.reloadData()
        if (indexPath.section == 1) && (self.collectionView?.numberOfItems(inSection: 1) == 0){
            let indexSet = IndexSet(integer: 1)
            self.collectionView?.reloadSections(indexSet)
        }
        
    }
    
    @objc func DoneTapped(_ sender: UIButton) {
        
        let index = IndexPath(row: sender.tag, section: 0)
        print("To delete \(index)")
        deleteTask(indexPathRow: sender.tag, section: 0)
        if !isEmpty {
            collectionView?.deleteItems(at: [index])
        }
        
        let indexSet = IndexSet(integer: 0)
        self.collectionView?.reloadSections(indexSet)
        
    }
    
    @objc func SnoozeTapped(_ sender: UIButton) {
        
        print(notifiedIndexes)
        let task = taskList![sender.tag]
        
        let modalController = ModalController()
        modalController.currentTask = task
        let navController = UINavigationController(rootViewController: modalController)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true, completion: nil)
        collectionView?.reloadData()
    }
    
    func deleteTask(indexPathRow: Int, section: Int) {
        var task: Task?
        let center = UNUserNotificationCenter.current()
        if section == 0 {
            task = taskList![indexPathRow]
            let notifToDelete = task?.uuid
            center.removePendingNotificationRequests(withIdentifiers: [notifToDelete!])
            
        }
        if section == 1 {
            task = todoList![indexPathRow]
        }
        
        print("Gotta delete ", task!)
        try! realm.write {
            realm.delete(task!)
        }
        
        if (taskList.count == 0) && (todoList.count == 0 ){
            isEmpty = true
        }
        
    }
    
    
    @objc func didAddTask(){
        getData()
        collectionView?.reloadData()
    }
    
    func getData(){
        taskList = realm.objects(Task.self).filter("noDate == false").sorted(byKeyPath: "notificationTime")
        todoList = realm.objects(Task.self).filter("noDate == true")
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
       
        if let userInfo = notification.userInfo {

            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            self.viewBottomConstraint.constant = isKeyboardShowing ? -(keyboardFrame?.height)! : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in })
        }
    }
    
    func clearTextField() {
        DataManager.shared.mainInput.text = ""
    }
    
    func setupNav() {
        let rightIcon: UIImage? = UIImage(named:"repeatuncolored")?.withRenderingMode(.alwaysOriginal)
        let rightIconButton = UIBarButtonItem(image: rightIcon, style: .plain, target: self, action: #selector(rightIconPushed))
        navigationItem.rightBarButtonItem = rightIconButton
    }
    
    @objc func rightIconPushed() {
        let repeatController = RepeatController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(repeatController, animated: true)
        
    }

}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

extension UILabel {
    func addCharactersSpacing(_ value: CGFloat = 1.15) {
        if let textString = text {
            let attrs: [NSAttributedStringKey : Any] = [.kern: value]
            attributedText = NSAttributedString(string: textString, attributes: attrs)
        }
    }
}

extension UICollectionView {
    
    func setEmptyMessage(image: UIImage, message: String, title: String) {
        self.backgroundView = EmptyState(image: image, text: message, title: title);
        
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension UIImage {
    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        color.set()
        withRenderingMode(.alwaysTemplate)
            .draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
