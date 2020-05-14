//
//  AttributedStringExtension.swift
//  Testing WWDC
//
//  Created by Thijs van der Heijden on 10/05/2020.
//  Copyright © 2020 Thijs van der Heijden. All rights reserved.
//

import UIKit

public extension NSMutableAttributedString {

    func bold(_ value:String, _ size: CGFloat) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.boldSystemFont(ofSize: size)
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func normal(_ value:String, _ size: CGFloat) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: size)
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
