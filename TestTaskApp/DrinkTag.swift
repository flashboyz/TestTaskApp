//
//  DrinkTag.swift
//  TestTaskApp
//
//  Created by Константин Прокофьев on 04.04.2022.
//

import Foundation
import UIKit

class DrinkTag: UIControl {
    var topInset = 4.0
    var bottomInset = 4.0
    var leftInset = 8.0
    var rightInset = 8.0
    var borderRadius = 8.0

    var gradientLayer:CAGradientLayer!
    var label: UILabel!
    
    var text: String? {
        get {
            label.text
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(str: String?) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(red: 0.7686, green: 0.7686, blue: 0.7686, alpha: 1)
        layer.cornerRadius = self.borderRadius
        layer.masksToBounds = true
        isUserInteractionEnabled = true
        
        label = UILabel()
        label.text = str
        label.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.bold)
        label.textColor = .white
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset))
        }
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 1, green: 0.3216, blue: 0.3843, alpha: 1).cgColor,
            UIColor(red: 0.9922, green: 0.3373, blue: 0.9922, alpha: 1).cgColor
        ]
    }
    
    override var intrinsicContentSize: CGSize {
        let size = label.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func select() {
        if !isSelected {
            isSelected = true
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func unselect() {
        if isSelected {
            isSelected = false
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    func toggleSelect() {
        isSelected ? unselect() : select()
    }
}
