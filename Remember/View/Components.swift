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
    
    func inactive() {
        if label.text == "No Date"{
            label.textColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
        }
    }
    
    func active() {
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    }
    
    func setupViews() {
        
        addSubview(label)
        
        addConstraintsWithFormat(format: "H:|-24-[v0]-24-|", views: label)
        addConstraintsWithFormat(format: "V:|-24-[v0]|", views: label)
        
    }
    
}

class HomeInput: Input {
    
    var textDelegate: HomeController?
    
    convenience init(superView: HomeController){
        self.init()
        textField.delegate = superView
        DataManager.shared.mainInput = textField
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class RepeatInput: Input {
    
    var textDelegate: RepeatController?
    
    convenience init(superView: RepeatController){
        self.init()
        textField.delegate = superView
        DataManager.shared.repeatInput = textField
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class Input: UIView {
    
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
        
        containerView.addSubview(textField)
        
        containerView.addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: textField)
        containerView.addConstraintsWithFormat(format: "V:|[v0]|", views: textField)
        
    }
}

class EmptyState: UIView {
    
    var didSetupConstraints = false
    
    let topView = UIView()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        label.addCharactersSpacing(0.6)
        return label
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.addCharactersSpacing(0.6)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    init(image: UIImage, text: String, title: String) {
        super.init(frame: CGRect.zero)
        setupViews()
        setupImageView(image: image)
        setupLabels(body: text, titleText: title)
    }
    
    func setupLabels(body: String, titleText: String) {
        let attributedString = NSMutableAttributedString(string: body)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6 // Whatever line spacing you want in points
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        label.textAlignment = .center
        
        title.text = titleText
        title.textAlignment = .center
    }
    
    func setupImageView(image: UIImage) {
        imageView.image = image
    }
    
    func setupViews() {
        
        let containerView = UIView()
        
        addSubview(containerView)
        
//        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: containerView)
        addConstraintsWithFormat(format: "V:[v0]-100-|", views: containerView)
        
        containerView.addSubview(topView)
        containerView.addSubview(imageView)
        containerView.addSubview(title)
        containerView.addSubview(label)
        
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        
        containerView.addConstraintsWithFormat(format: "V:[v3]-[v0(80)]-16-[v1]-12-[v2]", views: imageView,title,label,topView)
        topView.heightAnchor.constraint(greaterThanOrEqualToConstant: height*0.3).isActive = true
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        title.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
    }
    
}
