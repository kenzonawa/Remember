//
//  Buttons.swift
//  Todo.minders
//
//  Created by Victor Kenzo Nawa on 2/14/18.
//  Copyright © 2018 Victor Kenzo Nawa. All rights reserved.
//

import UIKit

class PrimaryButton: UIButton {
    
    let color = UIColor(red: 64/255, green: 101/255, blue: 225/255, alpha: 1).cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        
//        frame = CGRect(x: 0, y: 0, width: 104, height: 36)
        
        layer.backgroundColor = color
        layer.cornerRadius = 4
        
        
        setTitle("Done", for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        setTitleColor(UIColor.white , for: .normal)
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        
    }
    
}

class SecondaryButton: UIButton {
    
    let color = UIColor(red: 64/255, green: 101/255, blue: 225/255, alpha: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        
        layer.borderWidth = 2.0
        layer.borderColor = color.cgColor
        layer.cornerRadius = 4
        
        
        setTitle("Snooze", for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        setTitleColor(color , for: .normal)
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        
    }
    
}
