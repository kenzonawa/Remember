//
//  Components.swift
//  Todo.minders
//
//  Created by Victor Kenzo Nawa on 2/13/18.
//  Copyright © 2018 Victor Kenzo Nawa. All rights reserved.
//

import UIKit

public class Header: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = {
        let textField = UILabel()
        textField.text = "To Do"
        textField.font = UIFont.boldSystemFont(ofSize: 32)
        textField.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        return textField
    }()
    
    func setupViews() {
        
        addSubview(label)
        
        addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: label)
        addConstraintsWithFormat(format: "V:|-24-[v0]|", views: label)
        
    }
    
}

class Input: UIView {
    
    var textDelegate: HomeController?
    
    convenience init(superView: HomeController){
        self.init()
        textField.delegate = superView
        DataManager.shared.mainInput = textField
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var textField: UITextField = {
        let label = UITextField()
        label.placeholder = "Enter task"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    func setupViews() {
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
        containerView.layer.cornerRadius = 4
        
        addSubview(containerView)
        
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: containerView)
        addConstraintsWithFormat(format: "V:[v0(48)]", views: containerView)
        
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        textField.delegate = textDelegate
        containerView.addSubview(textField)
        
        containerView.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: textField)
        containerView.addConstraintsWithFormat(format: "V:|[v0]|", views: textField)
        
    }
}
