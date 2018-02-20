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

class RepeatController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    var viewBottomConstraint = NSLayoutConstraint()
    
    let realm = try! Realm()
    
    var repeatList: Results<RepeatTask>?
    
    var currentIndexPath: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        
        let taskInput: UIView = RepeatInput(superView: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeController.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeController.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
//        navigationItem.titleView = UIImageView(image: UIImage(named: "repeat"))
        navigationItem.title = "Repeat Reminders"
        let attributes = [
            NSAttributedStringKey.kern: 0.6,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .medium)
            ] as [NSAttributedStringKey : Any]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        
//        let backImage = UIImage(named: "logouncolored")
//        let backButton = UIButton(type: .custom)
//        backButton.setImage(backImage, for: .normal) // Image can be downloaded from here below link
//        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(RepeatCell.self, forCellWithReuseIdentifier: "repeatId")
        collectionView?.register(Header.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        view.addSubview(taskInput)
        
        // Pin the leading edge of myView to the margin's leading edge
        taskInput.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingConstraint = taskInput.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = taskInput.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        viewBottomConstraint = taskInput.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        let heightConstraint = taskInput.heightAnchor.constraint(equalToConstant: 72)
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, viewBottomConstraint, heightConstraint])
        
        DataManager.shared.repeatController = self
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! Header
            
            header.label.text = "Repeating Reminders"

            return header
            
        case UICollectionElementKindSectionFooter:
            
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerId", for: indexPath)
            
        default:
            return UICollectionReusableView()
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (repeatList?.count)!
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let task = repeatList![indexPath.item]
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "repeatId", for: indexPath) as! RepeatCell
        cell.updateUI(taskName: task.name, time: task.notificationTime)
        cell.updateFrequency(frequency: task.frequency, day: task.day)
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //currentIndexPath = indexPath.row
        var task: RepeatTask

        task = repeatList![indexPath.row]
            
        let modalController = RepeatModalController()
        modalController.currentTask = task
        let navController = UINavigationController(rootViewController: modalController)
        navController.isNavigationBarHidden = true
        navController.modalPresentationStyle = .overCurrentContext
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true, completion: nil)
        collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 86)
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        deleteTask(indexPathRow: indexPath.row, section: indexPath.section)
        collectionView.reloadData()
        
    }
    
    func deleteTask(indexPathRow: Int, section: Int) {
        var task: RepeatTask?
        let center = UNUserNotificationCenter.current()
        task = repeatList![indexPathRow]
        let notifToDelete = task?.uuid
        center.removePendingNotificationRequests(withIdentifiers: [notifToDelete!])
        
        print("Gotta delete ", task!)
        try! realm.write {
            realm.delete(task!)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func clearTextField() {
        DataManager.shared.repeatInput.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)  //if desired
        if textField.text! == "" {
            return true
        } else {
            
            let modalController = RepeatModalController()
            modalController.taskText = textField.text
            let navController = UINavigationController(rootViewController: modalController)
            navController.isNavigationBarHidden = true
            navController.modalPresentationStyle = .overCurrentContext
            navController.modalTransitionStyle = .crossDissolve
            present(navController, animated: true, completion: nil)
            
        }
        return true
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
    
    func getData(){
        repeatList = realm.objects(RepeatTask.self)
    }
    
    @objc func backAction() -> Void {
        self.navigationController?.popViewController(animated: true)
    }

    
}
