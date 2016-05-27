//
//  DropdownMenu.swift
//  DropdownMenu
//
//  Created by Suric on 16/5/26.
//  Copyright © 2016年 teambition. All rights reserved.
//

import UIKit

public protocol DropdownMenuDelegate: NSObjectProtocol {
    func dropdownMenu(dropdownMenu: DropdownMenu, didSelectRowAtIndexPath indexPath: NSIndexPath)
}

public class DropdownMenu: UIView {
    private weak var navigationController: UINavigationController!
    private var items: [DropdownItem] = []
    private var selectedRow: Int

    private var tableView: UITableView!
    private var barCoverView: UIView!
    private var isShow = false

    public weak var delegate: DropdownMenuDelegate?
    public var animateDuration: NSTimeInterval = 0.25
    public var backgroudBeginColor: UIColor = UIColor.blackColor().colorWithAlphaComponent(0)
    public var backgroudEndColor = UIColor(white: 0, alpha: 0.4)
    public var rowHeight: CGFloat = 50
    public var tableViewHeight: CGFloat = 0
    public var defaultBottonMargin: CGFloat = 150
    public var textColor: UIColor = UIColor(red: 56.0/255.0, green: 56.0/255.0, blue: 56.0/255.0, alpha: 1.0)
    public var highlightColor: UIColor = UIColor(red: 3.0/255.0, green: 169.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    public var checkmarkTintColor: UIColor = UIColor(red: 3.0/255.0, green: 169.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    public var tableViewBackgroundColor: UIColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    public var tableViewSeperatorColor = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    public var displaySelected: Bool = true


    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(navigationController: UINavigationController, items: [DropdownItem], selectedRow: Int = 0) {
        self.navigationController = navigationController
        self.items = items
        self.selectedRow = selectedRow

        let navigationBarFrame: CGRect = navigationController.navigationBar.frame
        let menuFrame: CGRect = CGRect(x: 0, y: (navigationBarFrame.height + navigationBarFrame.origin.y), width: navigationBarFrame.width, height: navigationController.view.frame.height - navigationBarFrame.height - navigationBarFrame.origin.y)
        super.init(frame: menuFrame)

        clipsToBounds = true
        setupGestureView()
        setupTableView()
    }

    private func setupNavigationBarCoverView() {
        barCoverView = UIView()
        barCoverView.backgroundColor = UIColor.clearColor()
        navigationController.view.addSubview(barCoverView)
        barCoverView.translatesAutoresizingMaskIntoConstraints = false

        let navigationBar = navigationController.navigationBar
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: barCoverView, attribute: .Top, relatedBy: .Equal, toItem: navigationBar, attribute: .Top, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: barCoverView, attribute: .Bottom, relatedBy: .Equal, toItem: navigationBar, attribute: .Bottom, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: barCoverView, attribute: .Left, relatedBy: .Equal, toItem: navigationBar, attribute: .Left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: barCoverView, attribute: .Right, relatedBy: .Equal, toItem: navigationBar, attribute: .Right, multiplier: 1.0, constant: 0)])
        barCoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideMenu)))
    }

    private func setupGestureView() {
        let gestureView = UIView()
        gestureView.backgroundColor = UIColor.clearColor()
        addSubview(gestureView)
        gestureView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: gestureView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: gestureView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: gestureView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: gestureView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)])

        gestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideMenu)))
    }

    private func setupTableView() {
        tableViewHeight = CGFloat(items.count) * rowHeight
        let navigationBarFrame: CGRect = navigationController.navigationBar.frame
        let maxHeight = navigationController.view.frame.height - navigationBarFrame.height + navigationBarFrame.origin.y - defaultBottonMargin
        if tableViewHeight > maxHeight {
            tableViewHeight = maxHeight
        }

        tableView = UITableView(frame: CGRect.zero, style: .Grouped)
        tableView.separatorColor = tableViewSeperatorColor
        tableView.backgroundColor = tableViewBackgroundColor
        tableView?.delegate = self
        tableView?.dataSource = self
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: tableViewHeight)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)])
    }

    public func showMenu() {
        if isShow {
            hideMenu()
            return
        }

        isShow = true
        setupNavigationBarCoverView()
        navigationController.view.insertSubview(self, belowSubview: navigationController.navigationBar)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: self, attribute: .Top, relatedBy: .Equal, toItem: navigationController.navigationBar, attribute: .Bottom, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: navigationController.view, attribute: .Bottom, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: self, attribute: .Left, relatedBy: .Equal, toItem: navigationController.view, attribute: .Left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: self, attribute: .Right, relatedBy: .Equal, toItem: navigationController.view, attribute: .Right, multiplier: 1.0, constant: 0)])

        backgroundColor = backgroudBeginColor
        self.tableView.frame.origin.y = -self.tableViewHeight
        UIView.animateWithDuration(animateDuration) {
            self.backgroundColor = self.backgroudEndColor
            self.tableView.frame.origin.y = 0
        }
    }

    public func hideMenu() {
        UIView.animateWithDuration(animateDuration, animations: {
            self.backgroundColor = self.backgroudBeginColor
            self.tableView.frame.origin.y = -self.tableViewHeight
        }) { (finished) in
            self.barCoverView.removeFromSuperview()
            self.removeFromSuperview()
            self.isShow = false
        }
    }
}

extension DropdownMenu: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "dropdownMenuCell")

        switch item.style {
        case .Default:
            cell.textLabel?.textColor = textColor
            if let image = item.image {
                cell.imageView?.image = image
            }
        case .Hightlight:
            cell.textLabel?.textColor = highlightColor
            if let image = item.image {
                let highlightImage = image.imageWithRenderingMode(.AlwaysTemplate)
                cell.imageView?.image = highlightImage
                cell.imageView?.tintColor = highlightColor
            }
        }

        cell.textLabel?.text = item.title
        if displaySelected && indexPath.row == selectedRow {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        cell.tintColor = checkmarkTintColor
        return cell
    }
}

extension DropdownMenu: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if displaySelected {
            let previousSelectedcell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0))
            previousSelectedcell?.accessoryType = .None
            selectedRow = indexPath.row
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        hideMenu()
        delegate?.dropdownMenu(self, didSelectRowAtIndexPath: indexPath)
    }
}
