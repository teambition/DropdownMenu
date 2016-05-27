//
//  DropdownItem.swift
//  DropdownMenu
//
//  Created by Suric on 16/5/27.
//  Copyright © 2016年 teambition. All rights reserved.
//

import UIKit

public enum DropdownItemStyle: Int {
    case Default
    case Hightlight
}

public class DropdownItem {
    public var image: UIImage?
    public var title: String
    public var style: DropdownItemStyle

    public init(image: UIImage?, title: String, style: DropdownItemStyle = .Default) {
        self.image = image
        self.title = title
        self.style = style
    }
}
