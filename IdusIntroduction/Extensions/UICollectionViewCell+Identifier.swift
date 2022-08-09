//
//  UICollectionViewCell+Identifier.swift
//  IdusIntroduction
//
//  Created by Hyoju Son on 2022/08/09.
//

import UIKit

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
