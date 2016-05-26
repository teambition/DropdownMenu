//
//  ViewController.swift
//  DropdownMenuDemo
//
//  Created by Suric on 16/5/26.
//  Copyright © 2016年 teambition. All rights reserved.
//

import UIKit
import DropdownMenu

class ViewController: UIViewController {
    var menuView: DropdownMenu!
    let images: [UIImage] = [UIImage(named: "file")!, UIImage(named: "post")!]
    let items: [String] = ["File", "Post"]

    override func viewDidLoad() {
        super.viewDidLoad()
        menuView = DropdownMenu(navigationController: navigationController!, images: images, items: items)
        menuView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showMenu(sender: AnyObject) {
        menuView.showMenu()
    }

}

extension ViewController: DropdownMenuDelegate {
    func dropdownMenu(dropdownMenu: DropdownMenu, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("DropdownMenu didselect \(indexPath.row) text:\(items[indexPath.row])")
    }
}
