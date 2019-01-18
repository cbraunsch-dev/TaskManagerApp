//
//  TitleValueContentView.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TitleValueCellContentView: UIView {
    let title = UILabel()
    let value = UILabel()
    
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
        
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.value.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.title)
        self.addSubview(self.value)
        
        self.title.font = UIFont.systemFont(ofSize: FontConstants.medium)
        self.value.font = UIFont.systemFont(ofSize: FontConstants.medium)
        
        self.title.textColor = UIColor.black
        self.value.textColor = UIColor.darkGray
        
        self.value.textAlignment = .right
        
        self.title.snp.makeConstraints { make in
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.5)
        }
        self.value.snp.makeConstraints { make in
            make.left.equalTo(self.title.snp.right)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.5)
        }
    }
}
