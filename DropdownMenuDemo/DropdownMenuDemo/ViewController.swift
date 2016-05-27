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
    let images: [UIImage] = [UIImage(named: "file")!, UIImage(named: "post")!]
    let items: [String] = ["File", "Post"]
    var selectedRow: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showMenu(sender: UIBarButtonItem) {
        let menuView = DropdownMenu(navigationController: navigationController!, images: images, items: items, selectedRow: selectedRow)
        menuView.delegate = self
        menuView.showMenu()
    }

}

extension ViewController: DropdownMenuDelegate {
    func dropdownMenu(dropdownMenu: DropdownMenu, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("DropdownMenu didselect \(indexPath.row) text:\(items[indexPath.row])")
        self.selectedRow = indexPath.row

        let alertConroller = UIAlertController(title: "Nice", message: "You choose \(items[indexPath.row])", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertConroller.addAction(okAction)
        presentViewController(alertConroller, animated: true) { 
            print("Display success")
        }
    }
}
