//
//  DropUpMenu.swift
//  DropUpMenu
//
//  Created by Suric on 16/8/11.
//  Copyright © 2016年 teambition. All rights reserved.
//

//
//  DropUpMenu.swift
//  DropUpMenu
//
//  Created by Suric on 16/5/26.
//  Copyright © 2016年 teambition. All rights reserved.
//

import UIKit

public protocol DropUpMenuDelegate: class {
    func dropUpMenu(dropUpMenu: DropUpMenu, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell?
    func dropUpMenu(dropUpMenu: DropUpMenu, didSelectRowAtIndexPath indexPath: NSIndexPath)
    func dropUpMenuCancel(dropUpMenu: DropUpMenu)
}

public extension DropUpMenuDelegate {
    func dropUpMenu(dropUpMenu: DropUpMenu, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        return nil
    }
    
    func dropUpMenu(dropUpMenu: DropUpMenu, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func dropUpMenuCancel(dropUpMenu: DropUpMenu) {
    }
}

private let screenRect = UIScreen.mainScreen().bounds

public class DropUpMenu: UIView {
    private var items: [DropdownItem] = []
    private var selectedRow: Int
    public var tableView: UITableView!
    private var barCoverView: UIView!
    private var isShow = false
    private var addedWindow: UIWindow?
    private var windowRootView: UIView?
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(self.hideMenu))
    }()
    
    public weak var delegate: DropUpMenuDelegate?
    public var animateDuration: NSTimeInterval = 0.25
    public var backgroudBeginColor: UIColor = UIColor.blackColor().colorWithAlphaComponent(0)
    public var backgroudEndColor = UIColor(white: 0, alpha: 0.4)
    public var rowHeight: CGFloat = 50
    public var tableViewHeight: CGFloat = 0
    public var defaultBottonMargin: CGFloat = 150
    public var textColor: UIColor = UIColor(red: 56.0/255.0, green: 56.0/255.0, blue: 56.0/255.0, alpha: 1.0)
    public var highlightColor: UIColor = UIColor(red: 3.0/255.0, green: 169.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    public var tableViewBackgroundColor: UIColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    public var tableViewSeperatorColor = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    public var displaySelected: Bool = true
    public var bottomOffsetY: CGFloat = 0
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(items: [DropdownItem], selectedRow: Int = 0, bottomOffsetY: CGFloat = 0) {
        self.items = items
        self.selectedRow = selectedRow
        self.bottomOffsetY = bottomOffsetY
        
        let frame = CGRect(x: 0, y: 0, width: screenRect.width, height: screenRect.height - bottomOffsetY)
        super.init(frame: frame)
        
        clipsToBounds = true
        setupGestureView()
        setupTableView()
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
        
        gestureView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupTopSeperatorView() {
        let seperatorView = UIView()
        seperatorView.backgroundColor = tableViewSeperatorColor
        addSubview(seperatorView)
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: seperatorView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: seperatorView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: seperatorView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: seperatorView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.5)])
    }
    
    private func setupTableView() {
        tableViewHeight = CGFloat(items.count) * rowHeight
        let maxHeight = UIScreen.mainScreen().bounds.height - bottomOffsetY
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
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant:0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: tableViewHeight)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)])
    }
    
    private func setupBottomCoverView(onView: UIView) {
        barCoverView = UIView()
        barCoverView.backgroundColor = UIColor.clearColor()
        barCoverView.translatesAutoresizingMaskIntoConstraints = false
        onView.addSubview(barCoverView)
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: barCoverView, attribute: .Bottom, relatedBy: .Equal, toItem: onView, attribute: .Bottom, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: barCoverView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: bottomOffsetY)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: barCoverView, attribute: .Left, relatedBy: .Equal, toItem: onView, attribute: .Left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: barCoverView, attribute: .Right, relatedBy: .Equal, toItem: onView, attribute: .Right, multiplier: 1.0, constant: 0)])
        barCoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideMenu)))
    }
    
    public func showMenu() {
        if isShow {
            hideMenu()
            return
        }
        isShow = true
        
        if let rootView = UIApplication.sharedApplication().keyWindow {
            windowRootView = rootView
        } else {
            addedWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
            addedWindow?.rootViewController = UIViewController()
            addedWindow?.hidden = false
            addedWindow?.makeKeyAndVisible()
            windowRootView = addedWindow!
        }
        setupBottomCoverView(windowRootView!)
        windowRootView?.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: self, attribute: .Top, relatedBy: .Equal, toItem: windowRootView, attribute: .Top, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: windowRootView, attribute: .Bottom, multiplier: 1.0, constant: -bottomOffsetY)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: self, attribute: .Left, relatedBy: .Equal, toItem: windowRootView, attribute: .Left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activateConstraints([NSLayoutConstraint.init(item: self, attribute: .Right, relatedBy: .Equal, toItem: windowRootView, attribute: .Right, multiplier: 1.0, constant: 0)])
        
        backgroundColor = backgroudBeginColor
        self.tableView.frame.origin.y = screenRect.height - bottomOffsetY
        UIView.animateWithDuration(animateDuration, delay: 0, options: UIViewAnimationOptions(rawValue: 7<<16), animations: {
            self.backgroundColor = self.backgroudEndColor
            self.tableView.frame.origin.y = screenRect.height - self.bottomOffsetY - self.tableViewHeight
            }, completion: nil)
    }
    
    public func hideMenu(isSelectAction isSelectAction: Bool = false) {
        UIView.animateWithDuration(animateDuration, animations: {
            self.backgroundColor = self.backgroudBeginColor
            self.tableView.frame.origin.y = screenRect.height - self.bottomOffsetY
        }) { (finished) in
            if !isSelectAction {
                self.delegate?.dropUpMenuCancel(self)
            }

            self.barCoverView.removeFromSuperview()
            self.removeFromSuperview()
            self.isShow = false
            
            if let _ = self.addedWindow {
                self.addedWindow?.hidden = true
                UIApplication.sharedApplication().keyWindow?.makeKeyWindow()
            }
        }
    }
}

extension DropUpMenu: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let customCell = delegate?.dropUpMenu(self, cellForRowAtIndexPath: indexPath) {
            return customCell
        }
        let item = items[indexPath.row]
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "dropUpMenuCell")
        
        switch item.style {
        case .Default:
            cell.textLabel?.textColor = textColor
            if let image = item.image {
                cell.imageView?.image = image
            }
        case .Highlight:
            cell.textLabel?.textColor = highlightColor
            if let image = item.image {
                let highlightImage = image.imageWithRenderingMode(.AlwaysTemplate)
                cell.imageView?.image = highlightImage
                cell.imageView?.tintColor = highlightColor
            }
        }
        
        cell.textLabel?.text = item.title
        cell.tintColor = highlightColor
        if displaySelected && indexPath.row == selectedRow {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        if let accesoryImage = item.accessoryImage {
            cell.accessoryView = UIImageView(image: accesoryImage)
        }
        
        return cell
    }
}

extension DropUpMenu: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if displaySelected {
            let item = items[indexPath.row]
            if item.accessoryImage  == nil {
                let previousSelectedcell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0))
                previousSelectedcell?.accessoryType = .None
                selectedRow = indexPath.row
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                cell?.accessoryType = .Checkmark
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        hideMenu(isSelectAction: true)
        delegate?.dropUpMenu(self, didSelectRowAtIndexPath: indexPath)
    }
}

