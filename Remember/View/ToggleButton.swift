//
//  ToggleButton.swift
//  Todo.minders
//
//  Created by Victor Kenzo Nawa on 2/12/18.
//  Copyright © 2018 Victor Kenzo Nawa. All rights reserved.
//

import UIKit

class ToggleButton: UIButton {
    
    var isOn = false
    
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
        layer.borderColor = UIColor.green.cgColor
        layer.cornerRadius = frame.size.height/2
        
        setTitleColor(UIColor.black , for: .normal)
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        activateButton(bool: !isOn)
    }
    
    func activateButton(bool: Bool) {
        
        isOn = bool
        
        let color = bool ? UIColor.blue : .clear
        let title = bool ? "Following" : "Follow"
        let titleColor = bool ? .white : UIColor.black
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = color
    }
    
    
}

