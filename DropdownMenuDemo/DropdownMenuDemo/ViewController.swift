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
    var selectedRow: Int = 0
    var items: [DropdownItem]!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        let item1 = DropdownItem(title: "NO Image")
        let item2 = DropdownItem(image: UIImage(named: "file")!, title: "File")
        let item3 = DropdownItem(image: UIImage(named: "post")!, title: "Post", style: .highlight)
        let item4 = DropdownItem(image: UIImage(named: "post")!, title: "Event", style: .highlight, accessoryImage: UIImage(named: "accessory")!)
        
        items = [item1, item2, item3, item4]
        let menuView = DropdownMenu(navigationController: navigationController!, items: items, selectedRow: selectedRow)
        menuView.delegate = self
        menuView.showMenu()
    }
    
    @IBAction func dropUpAction(_ sender: UIBarButtonItem) {
        let item1 = DropdownItem(title: "NO Image")
        let item2 = DropdownItem(image: UIImage(named: "file")!, title: "File")
        let item3 = DropdownItem(image: UIImage(named: "post")!, title: "Post", style: .highlight)
        let item4 = DropdownItem(image: UIImage(named: "post")!, title: "Event", style: .highlight, accessoryImage: UIImage(named: "accessory")!)
        
        items = [item1, item2, item3, item4]
        let menuView = DropUpMenu(items: items, selectedRow: 0, bottomOffsetY: self.tabBarController?.tabBar.frame.height ?? 0)
        menuView.delegate = self
        menuView.showMenu()
    }
}

extension ViewController: DropdownMenuDelegate {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath) {
        print("DropdownMenu didselect \(indexPath.row) text:\(items[indexPath.row].title)")
        if indexPath.row != items.count - 1 {
            self.selectedRow = indexPath.row
        }

        let alertConroller = UIAlertController(title: "Nice", message: "You choose \(items[indexPath.row].title)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertConroller.addAction(okAction)
        present(alertConroller, animated: true) {
            print("Display success")
        }
    }
}

extension ViewController: DropUpMenuDelegate {
    func dropUpMenu(_ dropUpMenu: DropUpMenu, didSelectRowAt indexPath: IndexPath) {
        let alertConroller = UIAlertController(title: "Nice", message: "DropUpMenu didselect \(indexPath.row) text:\(items[indexPath.row].title)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertConroller.addAction(okAction)
        present(alertConroller, animated: true) {
            print("Display success")
        }
    }
    
    func dropUpMenuCancel(_ dropUpMenu: DropUpMenu) {
        print("select cancel")
    }
}
