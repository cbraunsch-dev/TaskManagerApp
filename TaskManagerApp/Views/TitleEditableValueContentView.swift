//
//  TitleEditableValueContentView.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TitleEditableValueCellContentView: UIView {
    let title = UILabel()
    let valueText = UITextField()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.white
        self.addSubview(self.title)
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.valueText)
        self.valueText.translatesAutoresizingMaskIntoConstraints = false
        self.valueText.font = UIFont.systemFont(ofSize: FontConstants.medium)
        self.valueText.delegate = self
        
        self.title.snp.makeConstraints { make in
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.5)
        }
        self.valueText.snp.makeConstraints { make in
            make.left.equalTo(self.title.snp.right)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.5)
        }
    }
}

extension TitleEditableValueCellContentView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
