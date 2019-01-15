//
//  TitleEditableValueTableViewCell.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TitleEditableValueTableViewCell: UITableViewCell {
    let titleValueContent = TitleEditableValueCellContentView(frame: CGRect.zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    private func setupView() {
        self.contentView.addSubview(self.titleValueContent)
        self.titleValueContent.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(LayoutConstants.buX1_5)
            make.left.equalTo(self.contentView).offset(LayoutConstants.buX3)
            make.right.equalTo(self.contentView).offset(-LayoutConstants.buX3)
            make.bottom.equalTo(self.contentView).offset(-LayoutConstants.buX1_5)
        }
    }
}
