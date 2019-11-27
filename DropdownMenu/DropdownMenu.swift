//
//  DropdownMenu.swift
//  DropdownMenu
//
//  Created by Suric on 16/5/26.
//  Copyright © 2016年 teambition. All rights reserved.
//

import UIKit

public protocol DropdownMenuDelegate: class {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, heightForHeaderInSection section: Int) -> CGFloat
    func dropdownMenu(_ dropdownMenu: DropdownMenu, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    func dropdownMenu(_ dropdownMenu: DropdownMenu, cellForRowAt indexPath: IndexPath) -> UITableViewCell?
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath)
    func dropdownMenu(_ dropdownMenu: DropdownMenu, shouldDismissWhenSelectRowAt indexPath: IndexPath) -> Bool
    func dropdownMenu(_ dropdownMenu: DropdownMenu, shouldUpdateSelectionAt indexPath: IndexPath) -> Bool
    func dropdownMenuCancel(_ dropdownMenu: DropdownMenu)
    func dropdownMenuWillDismiss(_ dropdownMenu: DropdownMenu)
    func dropdownMenuWillShow(_ dropdownMenu: DropdownMenu)
}

public extension DropdownMenuDelegate {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, heightForHeaderInSection section: Int) -> CGFloat { return 44 }
    func dropdownMenu(_ dropdownMenu: DropdownMenu, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    func dropdownMenu(_ dropdownMenu: DropdownMenu, cellForRowAt indexPath: IndexPath) -> UITableViewCell? { return nil }
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath) { }
    func dropdownMenu(_ dropdownMenu: DropdownMenu, shouldDismissWhenSelectRowAt indexPath: IndexPath) -> Bool { return true }
    func dropdownMenu(_ dropdownMenu: DropdownMenu, shouldUpdateSelectionAt indexPath: IndexPath) -> Bool { return true }
    func dropdownMenuCancel(_ dropdownMenu: DropdownMenu) { }
    func dropdownMenuWillDismiss(_ dropdownMenu: DropdownMenu) { }
    func dropdownMenuWillShow(_ dropdownMenu: DropdownMenu) { }
}

open class DropdownMenu: UIView {
    private weak var navigationController: UINavigationController!
   
    private var sections: [DropdownSection] = []
    private var selectedIndexPath: IndexPath
    
    open var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        return tableView
    }()
    private var barCoverView: UIView?
    open var isShow = false
    private var addedWindow: UIWindow?
    private var windowRootView: UIView?
    private var topConstraint: NSLayoutConstraint?
    private var navigationBarCoverViewHeightConstraint: NSLayoutConstraint?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private let iPhoneXPortraitTopOffset: CGFloat = 88.0
    private let portraitTopOffset: CGFloat = 64.0
    private let landscapeTopOffset: CGFloat = 32.0
    
    private var topLayoutConstraintConstant: CGFloat {
        var offset: CGFloat = 0
        if !navigationController.isNavigationBarHidden {
            if let navigationBarWindow = navigationController.view.window {
                let convertRect = navigationController.view.convert(navigationController.navigationBar.frame, to: navigationBarWindow)
                offset = convertRect.height + convertRect.origin.y
            } else {
                offset = navigationController.navigationBar.frame.height + navigationController.navigationBar.frame.origin.y
            }
        }
        return offset + topOffsetY
    }
    
    open weak var delegate: DropdownMenuDelegate?
    open var animateDuration: TimeInterval = 0.25
    open var backgroudBeginColor: UIColor = UIColor.black.withAlphaComponent(0)
    open var backgroudEndColor = UIColor(white: 0, alpha: 0.4)
    open var rowHeight: CGFloat = 50
    open var tableViewHeight: CGFloat = 0
    open var defaultBottonMargin: CGFloat = 150
    open var topOffsetY: CGFloat = 0
    
    open var textFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    open var textColor: UIColor = UIColor(red: 56.0/255.0, green: 56.0/255.0, blue: 56.0/255.0, alpha: 1.0)
    open var highlightColor: UIColor = UIColor(red: 3.0/255.0, green: 169.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    open var tableViewBackgroundColor: UIColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0) {
        didSet {
            tableView.backgroundColor = tableViewBackgroundColor
        }
    }
    open var separatorStyle: UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            tableView.separatorStyle = separatorStyle
        }
    }
    open var tableViewSeperatorColor = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0) {
        didSet {
            tableView.separatorColor = tableViewSeperatorColor
        }
    }
    open var zeroInsetSeperatorIndexPaths: [IndexPath] = []
    
    open var cellBackgroundColor = UIColor.white
    
    open var displaySelected: Bool = true
    open var displaySectionHeader: Bool = false
    open var displayNavigationBarCoverView: Bool = true
    
    // section header sytle
    open var sectionHeaderStyle: SectionHeaderStyle = SectionHeaderStyle()
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(navigationController: UINavigationController, items: [DropdownItem], selectedRow: Int = 0) {
        self.navigationController = navigationController
        self.sections = [DropdownSection(sectionIdentifier: "", items: items)]
        self.selectedIndexPath = IndexPath(row: selectedRow, section: 0)
        
        super.init(frame: CGRect.zero)
        
        clipsToBounds = true
        setupGestureView()
        setupTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateForOrientationChange(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
    }
    
    public init(navigationController: UINavigationController, sections: [DropdownSection], selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0), dispalySectionHeader: Bool = true, sectionHeaderStyle: SectionHeaderStyle = SectionHeaderStyle()) {
        self.navigationController = navigationController
        self.sections = sections
        self.selectedIndexPath = selectedIndexPath
        self.displaySectionHeader = dispalySectionHeader
        
        super.init(frame: CGRect.zero)
        
        clipsToBounds = true
        setupGestureView()
        setupTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateForOrientationChange(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
    }

    public func updateItems(_ items: [DropdownItem]) {
        self.sections = [DropdownSection(sectionIdentifier: "", items: items)]
        self.tableView.beginUpdates()
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        self.tableView.endUpdates()
        updateForSectionsChange()
    }

    public func updateSections(_ sections: [DropdownSection]) {
        self.sections = sections
        self.tableView.reloadData()
        updateForSectionsChange()
    }

    public func updateItems(_ items: [DropdownItem], inSection section: Int) {
        guard 0..<self.sections.count ~= section else {
            return
        }
        var dropdownSection = self.sections[section]
        dropdownSection.items = items
        self.sections[section] = dropdownSection
        self.tableView.beginUpdates()
        self.tableView.reloadSections(IndexSet(integer: section), with: .fade)
        self.tableView.endUpdates()
        updateForSectionsChange()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateForOrientationChange(_ nofication: Notification) {
        if let oriention = (nofication as NSNotification).userInfo?[UIApplication.statusBarOrientationUserInfoKey] as? Int {
            var topOffset: CGFloat
            switch oriention {
            case UIInterfaceOrientation.landscapeLeft.rawValue, UIInterfaceOrientation.landscapeRight.rawValue:
                if UIDevice.current.userInterfaceIdiom == .phone {
                    topOffset = landscapeTopOffset
                } else {
                    topOffset = navigationController.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
                }
            default:
                if UIScreen.main.bounds.width == 812 {
                    topOffset = iPhoneXPortraitTopOffset
                } else {
                    topOffset = portraitTopOffset
                }
            }
            topOffset = topOffset + topOffsetY
            topConstraint?.constant = topOffset
            navigationBarCoverViewHeightConstraint?.constant = topOffset
            UIView.animate(withDuration: 0.1, animations: {
                self.windowRootView?.layoutIfNeeded()
            })
        }
    }
    
    private func setupGestureView() {
        let gestureView = UIView()
        gestureView.backgroundColor = UIColor.clear
        addSubview(gestureView)
        gestureView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: gestureView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: gestureView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: gestureView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: gestureView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)])
        
        gestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideMenu)))
    }
    
    private func setupTableView() {
        tableView.separatorStyle = separatorStyle
        tableView.delegate = self
        tableView.dataSource = self
        addSubview(tableView)
    }
    
    private func layoutTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        updateTableViewHeight()
        
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: tableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant:0)])
        let tableViewHeightConstraint = NSLayoutConstraint.init(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: tableViewHeight)
        NSLayoutConstraint.activate([tableViewHeightConstraint])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: tableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: tableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)])
        self.tableViewHeightConstraint = tableViewHeightConstraint
    }

    private func updateTableViewHeight() {
        tableViewHeight = tableviewHeight()
        
        let maxHeight = navigationController.view.frame.height - topLayoutConstraintConstant - defaultBottonMargin
        
        if tableViewHeight > maxHeight {
            if displaySectionHeader {
                tableViewHeight = maxHeight
            } else {
                tableViewHeight = round(maxHeight / rowHeight) * rowHeight
            }
        }
    }

    private func updateForSectionsChange(_ animations: (() -> Void)? = nil) {
        updateTableViewHeight()
        tableViewHeightConstraint?.constant = tableViewHeight
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            animations?()
            strongSelf.layoutIfNeeded()
        }
    }
    
    private func setupTopSeperatorView() {
        let seperatorView = UIView()
        seperatorView.backgroundColor = tableViewSeperatorColor
        addSubview(seperatorView)
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: seperatorView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: seperatorView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: seperatorView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: seperatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.5)])
    }
    
    private func setupNavigationBarCoverView(on view: UIView) {
        barCoverView = UIView()
        barCoverView?.backgroundColor = UIColor.clear
        view.addSubview(barCoverView!)
        barCoverView?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: barCoverView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)])
        navigationBarCoverViewHeightConstraint = NSLayoutConstraint.init(item: barCoverView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: topLayoutConstraintConstant)
        NSLayoutConstraint.activate([navigationBarCoverViewHeightConstraint!])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: barCoverView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: barCoverView!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)])
        barCoverView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideMenu)))
    }
    
    private func tableviewHeight() -> CGFloat {
        var height: CGFloat = 0
        sections.enumerated().forEach {
            if displaySectionHeader {
                let sectionHeaderHeight = delegate?.dropdownMenu(self, heightForHeaderInSection: $0) ?? 44
                height += sectionHeaderHeight
            }
            height += CGFloat($1.items.count) * rowHeight
        }
        return height
    }
    
    open func showMenu(isOnNavigaitionView: Bool = false) {
        delegate?.dropdownMenuWillShow(self)
        if isShow {
            hideMenu()
            return
        }
        
        isShow = true
        
        layoutTableView()
        setupTopSeperatorView()
        
        if let rootView = UIApplication.shared.keyWindow {
            windowRootView = rootView
        } else {
            addedWindow = UIWindow(frame: UIScreen.main.bounds)
            addedWindow?.rootViewController = UIViewController()
            addedWindow?.isHidden = false
            addedWindow?.makeKeyAndVisible()
            windowRootView = addedWindow!
        }
        
        if displayNavigationBarCoverView {
            setupNavigationBarCoverView(on: windowRootView!)
        }
        
        windowRootView?.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        topConstraint = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: windowRootView, attribute: .top, multiplier: 1.0, constant: topLayoutConstraintConstant)
        NSLayoutConstraint.activate([topConstraint!])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: windowRootView, attribute: .bottom, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: self, attribute: .left, relatedBy: .equal, toItem: windowRootView, attribute: .left, multiplier: 1.0, constant: 0)])
        NSLayoutConstraint.activate([NSLayoutConstraint.init(item: self, attribute: .right, relatedBy: .equal, toItem: windowRootView, attribute: .right, multiplier: 1.0, constant: 0)])
        
        backgroundColor = backgroudBeginColor
        self.tableView.frame.origin.y = -self.tableViewHeight
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(rawValue: 7<<16), animations: {
            self.backgroundColor = self.backgroudEndColor
            self.tableView.frame.origin.y = 0
        }, completion: nil)
    }
    
    @objc open func hideMenu(isSelectAction: Bool = false) {
        delegate?.dropdownMenuWillDismiss(self)
        UIView.animate(withDuration: animateDuration, animations: {
            self.backgroundColor = self.backgroudBeginColor
            self.tableView.frame.origin.y = -self.tableViewHeight
        }, completion: { (finished) in
            if !isSelectAction {
                self.delegate?.dropdownMenuCancel(self)
            }
            self.barCoverView?.removeFromSuperview()
            self.removeFromSuperview()
            self.isShow = false
            
            if let _ = self.addedWindow {
                self.addedWindow?.isHidden = true
                UIApplication.shared.keyWindow?.makeKey()
            }
        })
    }
}

extension DropdownMenu: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.dropdownMenu(self, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let customCell = delegate?.dropdownMenu(self, cellForRowAt: indexPath) {
            return customCell
        }
        
        let item = sections[indexPath.section].items[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "dropdownMenuCell")
        
        switch item.style {
        case .default:
            cell.textLabel?.textColor = textColor
            if let image = item.image {
                cell.imageView?.image = image
            }
        case .highlight:
            cell.textLabel?.textColor = highlightColor
            if let image = item.image {
                let highlightImage = image.withRenderingMode(.alwaysTemplate)
                cell.imageView?.image = highlightImage
                cell.imageView?.tintColor = highlightColor
            }
        }
        
        cell.textLabel?.text = item.title
        cell.textLabel?.font = textFont
        cell.tintColor = highlightColor
        cell.backgroundColor = cellBackgroundColor
        
        if displaySelected && indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if let accesoryImage = item.accessoryImage {
            cell.accessoryView = UIImageView(image: accesoryImage)
        }
        
        if zeroInsetSeperatorIndexPaths.contains(indexPath) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.layoutMargins.left, bottom: 0, right: 0)
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return displaySectionHeader ? sections[section].sectionIdentifier : nil
    }
}

extension DropdownMenu: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard displaySectionHeader else {
            return .leastNormalMagnitude
        }
        return delegate?.dropdownMenu(self, heightForHeaderInSection: section) ?? 44
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shouldUpdateSelection = delegate?.dropdownMenu(self, shouldUpdateSelectionAt: indexPath) ?? true
        if displaySelected && shouldUpdateSelection {
            let item = sections[indexPath.section].items[indexPath.row]
            if item.accessoryImage  == nil {
                let previousSelectedcell = tableView.cellForRow(at: selectedIndexPath)
                previousSelectedcell?.accessoryType = .none
                selectedIndexPath = indexPath
                let cell = tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .checkmark
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        let shouldDismiss = delegate?.dropdownMenu(self, shouldDismissWhenSelectRowAt: indexPath) ?? true
        if shouldDismiss {
            hideMenu(isSelectAction: true)
        }
        delegate?.dropdownMenu(self, didSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dropdownSection = sections[section]
        if let customSectionHeader = dropdownSection.customSectionHeader {
            return customSectionHeader
        } else {
            let sectionHeader = SectionHeader(style: sectionHeaderStyle)
            sectionHeader.titleLabel.text = dropdownSection.sectionIdentifier
            return sectionHeader
        }
    }
}
