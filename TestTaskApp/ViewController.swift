//
//  ViewController.swift
//  TestTaskApp
//
//  Created by Константин Прокофьев on 01.04.2022.
//

import Alamofire
import UIKit
import SnapKit


class ViewController: UIViewController {
    var cloudView: UIScrollView!
    var drinkSearchField: UITextField!
    
    var cachedDrinks:[Drink] = []
    var tags:[DrinkTag] = []
    var selectedDrinkNames:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagCloudSetup()
        textFieldSetup()
        fetchDrinks(url: "https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Non_Alcoholic")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    
    func renderTags(drinks: [Drink]) {
        cloudView.subviews.forEach({ $0.removeFromSuperview() })
        tags.removeAll()
        
        var prevTag:DrinkTag!
        var lineWidth = 0.0
        let rowGap = 8.0
        var verticalOffset = rowGap
        let horizontalOffset = 8.0
        
        for drink in drinks {
            let tag = DrinkTag(str: drink.strDrink)
            tag.addTarget(self, action: #selector(ViewController.tagOnTap), for: UIControl.Event.touchDown)
            if selectedDrinkNames.first(where: {$0 == drink.strDrink}) != nil {
                tag.select()
            }
            tags.append(tag)
            let tagSize = tag.intrinsicContentSize
            cloudView.addSubview(tag)
            tag.snp.makeConstraints { make in
                make.width.equalTo(tagSize.width)
                make.height.equalTo(tagSize.height)
                
                let predictLineWidth = lineWidth + tagSize.width + 2 * horizontalOffset
                var left = cloudView.snp.left
                if prevTag !== nil && predictLineWidth < cloudView.frame.width {
                    left = prevTag.snp.right
                }
                if predictLineWidth > cloudView.frame.width {
                    verticalOffset += tagSize.height + rowGap
                    cloudView.contentSize.height = verticalOffset + tagSize.height + rowGap + drinkSearchField.frame.height + 8
                    lineWidth = 0
                }
                make.left.equalTo(left).offset(horizontalOffset)
                make.top.equalTo(verticalOffset)
            }
            
            prevTag = tag
            lineWidth += tagSize.width + horizontalOffset
        }
    }
    
    @objc func tagOnTap(sender: DrinkTag) {
        if sender.isSelected {
            sender.unselect()
            selectedDrinkNames = selectedDrinkNames.filter { $0 != sender.text }
        } else {
            sender.select()
            selectedDrinkNames.append(sender.text!)
        }
    }
    
    @objc func searchDrink() {
        tags.forEach { tag in
            tag.unselect()
            selectedDrinkNames = selectedDrinkNames.filter { $0 != tag.text }
            
            let drinkName = tag.label.text ?? ""
            let pattern = drinkSearchField.text ?? ""
            
            if drinkName.count > 0
                && pattern.count > 0
                && drinkName.contains(pattern) {
                tag.select()
                selectedDrinkNames.append(tag.text!)
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        placeDrinkSearchFieldPinned()
    }
    
    @objc func keyboardWillHide() {
        placeDrinkSearchFieldBottom()
    }
    
    @objc func orientationChanged() {
        renderTags(drinks: cachedDrinks)
    }
    
}


//MARK: - extension for ViewController

extension ViewController {
    
    private func fetchDrinks(url: String) {
        AF.request(url).responseDecodable(of:DrinksResponse.self) { response in
            switch response.result {
            case .success(let data):
                self.cachedDrinks = data.drinks
                self.renderTags(drinks: data.drinks)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func tagCloudSetup() {
        cloudView = UIScrollView()
        view.addSubview(cloudView)
        cloudView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
    }
    
    private func textFieldSetup() {
        drinkSearchField = UITextField()
        drinkSearchField.placeholder = "Coctail name"
        drinkSearchField.layer.shadowColor = UIColor.gray.cgColor
        drinkSearchField.layer.shadowRadius = 4
        drinkSearchField.layer.shadowOpacity = 1
        drinkSearchField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        drinkSearchField.borderStyle = .roundedRect
        view.addSubview(drinkSearchField)
        placeDrinkSearchFieldBottom()
        drinkSearchField.addTarget(self, action: #selector(ViewController.searchDrink), for: .editingChanged)
    }
    
    private func placeDrinkSearchFieldBottom() {
        self.drinkSearchField.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.5)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-8)
        }
    }
    
    private func placeDrinkSearchFieldPinned() {
        drinkSearchField.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(8)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
    }
}

