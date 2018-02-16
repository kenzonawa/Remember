//
//  Extensions.swift
//  Todo.minders
//
//  Created by Victor Kenzo Nawa on 2/13/18.
//  Copyright © 2018 Victor Kenzo Nawa. All rights reserved.
//

import UIKit

class TaskCell: BaseTaskCell {
    
    override func setupViews() {
        
        setDelete()
        setupContainerView(active: true)
        
    }
    
}

class NotifiedCell: BaseTaskCell {
    
    var primaryButton = PrimaryButton()
    
    var secondaryButton = SecondaryButton()
    
    override func setupViews() {
        
        setDelete()
        setupContainerView(active: false)
        
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
        setupContainerView(active: false)
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
    
    override func setupViews() {
        
        setDelete()
        setupContainerView(active: true)
        
    }
    
    func setDelete() {
        
        deleteLabel1 = UILabel()
        deleteLabel1.text = "delete"
        deleteLabel1.textColor = UIColor.black
        self.insertSubview(deleteLabel1, belowSubview: self.contentView)
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        pan.delegate = self
        self.addGestureRecognizer(pan)
        
    }
    
    func setupContainerView(active: Bool) {
        let containerView = UIView()
        addSubview(containerView)
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 4
        //        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        containerView.layer.shadowRadius = 4
        
        if active {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.width-48, height: 4)
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.colors = [UIColor(red: 203/255, green: 0/255, blue: 238/255, alpha: 1).cgColor, UIColor(red: 0/255, green: 116/255,   blue: 239/255, alpha: 1).cgColor]
            containerView.layer.addSublayer(gradientLayer)
        } else {
            top.backgroundColor = UIColor.lightGray
        }
        
        addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: containerView)
        addConstraintsWithFormat(format: "V:|-8-[v0]-8-|", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(top)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: top)
        addConstraintsWithFormat(format: "V:|[v0(4)]", views: top)
        
        containerView.addConstraintsWithFormat(format: "H:|-12-[v0][v1(80)]-12-|", views: nameLabel, dateLabel)
        containerView.addConstraintsWithFormat(format: "V:|-26-[v0]", views: nameLabel)
        containerView.addConstraintsWithFormat(format: "H:[v0]-12-|", views: timeLabel)
        containerView.addConstraintsWithFormat(format: "V:|-18-[v0(15)]-[v1(15)]", views: dateLabel, timeLabel)
        
        container = containerView
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if (pan.state == UIGestureRecognizerState.changed) {
            let p: CGPoint = pan.translation(in: self)
            let width = self.contentView.frame.width
            let height = self.contentView.frame.height
            self.contentView.frame = CGRect(x: p.x,y: 0, width: width, height: height)
            
            self.container.frame = CGRect(x: p.x+16, y: 8, width: self.container.frame.width, height: self.container.frame.height)
            self.deleteLabel1.frame = CGRect(x: p.x - deleteLabel1.frame.size.width-10, y: 0, width: 100, height: height)
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
            self.setNeedsLayout()
        } else {
            if abs(pan.velocity(in: self).x) > 500 {
                let collectionView: UICollectionView = self.superview as! UICollectionView
                let indexPath: IndexPath = collectionView.indexPathForItem(at: self.center)!
                collectionView.delegate?.collectionView!(collectionView, performAction: #selector(onPan), forItemAt: indexPath, withSender: nil)
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
