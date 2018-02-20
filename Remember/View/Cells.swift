//
//  Extensions.swift
//  Todo.minders
//
//  Created by Victor Kenzo Nawa on 2/13/18.
//  Copyright © 2018 Victor Kenzo Nawa. All rights reserved.
//

import UIKit

class RepeatCell: BaseTaskCell {
    
    var textToDisplay = "Every "
    
    let frequencyLabel: UILabel = {
        let label = UILabel()
        label.text = "Everyday"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .right
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        return label
    }()
    
    override func setupViews() {
        
        setDelete()
        setupContainerView(active: "active")
        dateLabel.isHidden = true
        timeLabel.removeFromSuperview()
        container.addSubview(timeLabel)
        nameLabel.removeFromSuperview()
        container.addSubview(nameLabel)
        container.addSubview(frequencyLabel)
        
        container.addConstraintsWithFormat(format: "H:|-12-[v0]", views: nameLabel)
        container.addConstraintsWithFormat(format: "H:|-12-[v0]", views: timeLabel)
        container.addConstraintsWithFormat(format: "V:|-16-[v0(20)]-[v1(12)]", views: nameLabel,timeLabel)
        
        container.addConstraintsWithFormat(format: "H:[v0(80)]-12-|", views: frequencyLabel)
        frequencyLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 2).isActive = true
        
//        container.addConstraintsWithFormat(format: "V:|-20-[v0]", views: frequencyLabel)
    
    }
    
    func updateFrequency(frequency: String, day: String) {
        
        switch frequency{
        case "daily":
            textToDisplay = "Everyday"
        case "weekly":
            textToDisplay = "Every \(day)"
        case "monthly":
            textToDisplay = "Every \(day) of the month"
        default:
            textToDisplay = "Default"
        }
        frequencyLabel.text = textToDisplay
    }
}

class TaskCell: BaseTaskCell {
    
    override func setupViews() {
        
        setDelete()
        setupContainerView(active: "active")
        
    }
    
}

class NotifiedCell: BaseTaskCell {
    
    var primaryButton = PrimaryButton()
    
    var secondaryButton = SecondaryButton()
    
    override func setupViews() {
        
        setDelete()
        setupContainerView(active: "notified")
        
        container.addSubview(primaryButton)
        container.addSubview(secondaryButton)
        
        container.addConstraintsWithFormat(format: "H:[v0(104)]-12-|", views: primaryButton)
        container.addConstraintsWithFormat(format: "V:[v0(36)]-16-|", views: primaryButton)
        
        container.addConstraintsWithFormat(format: "H:|-12-[v0(104)]", views: secondaryButton)
        container.addConstraintsWithFormat(format: "V:[v0(36)]-16-|", views: secondaryButton)
        
    }
    
}

class TodoCell: BaseTaskCell {
    
    let setReminder: UILabel = {
        let label = UILabel()
        label.text = "Set\nReminder"
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.medium)
        label.textColor = UIColor(red: 64/255, green: 101/255, blue: 225/255, alpha: 1)
        label.textAlignment = .center
        label.addCharactersSpacing(0.6)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    
    override func setupViews() {
        
        setDelete()
        setupContainerView(active: "todo")
        timeLabel.isHidden = true
        dateLabel.isHidden = true
        
        container.addSubview(setReminder)
        container.addConstraintsWithFormat(format: "H:[v0]-12-|", views: setReminder)
        container.addConstraintsWithFormat(format: "V:|-20-[v0]", views: setReminder)
        
    }
    
}

public class BaseTaskCell: BaseCell, UIGestureRecognizerDelegate {
    
    var deleteLabel1: UILabel!
    
    var container: UIView!
    
    var pan: UIPanGestureRecognizer!
    
    var identity: CGAffineTransform?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Task"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:05 PM"
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
        label.textAlignment = .right
        label.addCharactersSpacing(0.6)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Today"
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        label.textAlignment = .right
        //label.addCharactersSpacing()
        return label
    }()
    
    let top: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let topContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    override func setupViews() {
        
        setDelete()
        setupContainerView(active: "active")
        
    }
    
    func setDelete() {
        
        deleteLabel1 = UILabel()
        deleteLabel1.text = "Delete"
        deleteLabel1.textColor = UIColor(red: 255/255, green: 83/255, blue: 38/255, alpha: 1)
        deleteLabel1.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        deleteLabel1.addCharactersSpacing(0.6)
        deleteLabel1.layer.shadowColor = UIColor(red: 255/255, green: 83/255, blue: 38/255, alpha: 1).cgColor
        deleteLabel1.layer.shadowRadius = 2.0
        deleteLabel1.layer.shadowOpacity = 0.3
        deleteLabel1.layer.shadowOffset = CGSize(width: 0, height: 0)
        deleteLabel1.layer.masksToBounds = false
        deleteLabel1.frame = CGRect(x: -110 , y: 0, width: 100, height: self.contentView.frame.height)
        self.insertSubview(deleteLabel1, belowSubview: self.contentView)
        identity = self.deleteLabel1.transform
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        pan.delegate = self
        self.addGestureRecognizer(pan)
        
    }
    
    func setupContainerView(active: String) {
        let containerView = UIView()
        addSubview(containerView)
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 4
        //        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.16
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowRadius = 4
        
        if active == "active" {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.width-48, height: 4)
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.colors = [UIColor(red: 203/255, green: 0/255, blue: 238/255, alpha: 1).cgColor, UIColor(red: 0/255, green: 116/255,   blue: 239/255, alpha: 1).cgColor]
            topContainer.layer.addSublayer(gradientLayer)
        } else if active == "notified" {
            top.backgroundColor = UIColor(red: 208/255, green: 207/255, blue: 212/255, alpha: 1)
            topContainer.addSubview(top)
            topContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: top)
            topContainer.addConstraintsWithFormat(format: "V:|[v0(4)]", views: top)
        } else if active == "todo" {
            top.backgroundColor = UIColor(red: 171/255, green: 185/255, blue: 232/255, alpha: 1)
            topContainer.addSubview(top)
            topContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: top)
            topContainer.addConstraintsWithFormat(format: "V:|[v0(4)]", views: top)
        }
        
        addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: containerView)
        addConstraintsWithFormat(format: "V:|-8-[v0]-8-|", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(topContainer)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: topContainer)
        addConstraintsWithFormat(format: "V:|[v0(8)]", views: topContainer)
        
        containerView.addConstraintsWithFormat(format: "H:|-12-[v0][v1(80)]-12-|", views: nameLabel, dateLabel)
        containerView.addConstraintsWithFormat(format: "V:|-26-[v0]", views: nameLabel)
        
        containerView.addConstraintsWithFormat(format: "H:[v0]-12-|", views: timeLabel)
        containerView.addConstraintsWithFormat(format: "V:|-18-[v0(15)]-[v1(15)]", views: dateLabel, timeLabel)
        
        container = containerView
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if pan.state == UIGestureRecognizerState.ended {
            deleteLabel1.frame = CGRect(x: -110 , y: 0, width: 100, height: self.contentView.frame.height)
        }
        
        if (pan.state == UIGestureRecognizerState.changed) {
            let p: CGPoint = pan.translation(in: self)
            let width = self.contentView.frame.width
            let height = self.contentView.frame.height
            self.contentView.frame = CGRect(x: p.x,y: 0, width: width, height: height)
            
            self.container.frame = CGRect(x: p.x+16, y: 8, width: self.container.frame.width, height: self.container.frame.height)
            
            self.deleteLabel1.frame = CGRect(x: p.x - deleteLabel1.frame.size.width + 16, y: 0, width: 100, height: height)
            
            var scale = p.x*0.007
            if scale > 1 { scale = 1}
            self.deleteLabel1.transform = identity!.scaledBy(x: scale , y: scale )
        }
        
    }
    
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: self)
            if fabs(translation.y) < fabs(translation.x) {
                return true
            }
            return false
        }
        return false
    }
    
    @objc func onPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == UIGestureRecognizerState.began {
        } else if pan.state == UIGestureRecognizerState.changed {
            if (pan.translation(in: self).x) > 0 {
                self.setNeedsLayout()
            }
        } else {
            if pan.translation(in: self).x > 140 {
                
                // DELETE
                let collectionView: UICollectionView = self.superview as! UICollectionView
                let indexPath: IndexPath = collectionView.indexPathForItem(at: self.center)!
                
                
                
                UIView.animate(withDuration: 0.5, animations: {
                    print("doing the animation??")
                    
                    self.deleteLabel1.frame = CGRect(x: 700, y: 0, width: 100, height: self.contentView.frame.height)
                    
                    self.container.frame = CGRect(x: 700, y: 8, width: self.container.frame.width, height: self.container.frame.height)
                    
                    }, completion: { finished in
                        
                        collectionView.delegate?.collectionView!(collectionView, performAction: #selector(self.onPan), forItemAt: indexPath, withSender: nil)
                        })
                
               
                
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    func updateUI(taskName: String , time: Date){
        
        nameLabel.text = taskName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        var timeString: String
        timeString = dateFormatter.string(from: time)
        if timeString.hasPrefix("0") {
            timeString.remove(at: timeString.startIndex)
        }
        
        timeLabel.text = timeString
        
        var dateString: String
        
        let calendar = NSCalendar.current
        if calendar.isDateInToday(time) { dateString = "Today" }
        else if calendar.isDateInTomorrow(time) { dateString = "Tomorrow" }
        else {
            dateFormatter.dateFormat = "MMM dd"
            dateString = dateFormatter.string(from: time)
        }
        
        dateLabel.text = dateString

    }
    
}

class Footer: BaseCell {
    
    override func setupViews() {
        self.backgroundColor = .white
        
    }
}

class EmptyStateCell: BaseCell {
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "To start adding reminders, write a task on the bottom text field"
        label.textAlignment = .center
        return label
    }()
    
    override func setupViews() {
        addSubview(emptyLabel)
        emptyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        emptyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    }
    
}

public class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
    }
}
