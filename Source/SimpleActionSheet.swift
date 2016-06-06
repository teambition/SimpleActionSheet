//
//  SimpleActionSheet.swift
//  SimpleActionSheet
//
//  Created by Zhu Shengqi on 6/6/16.
//  Copyright © 2016 dia. All rights reserved.
//

import UIKit
import SnapKit

// MARK: - SimpleActionSheetDataSource
public protocol SimpleActionSheetDataSource: class {
    func numberOfActionCellsFor(actionSheet: SimpleActionSheet) -> Int
    
    func heightForActionCellAt(row: Int, forActionSheet actionSheet: SimpleActionSheet) -> CGFloat
    
    func actionCellAt(row: Int, forActionSheet actionSheet: SimpleActionSheet) -> UITableViewCell
    
    func cancellingButtonFor(actionSheet: SimpleActionSheet) -> UIButton?
}

extension SimpleActionSheetDataSource {
    func numberOfActionCellsFor(actionSheet: SimpleActionSheet) -> Int {
        return 0
    }
    
    func heightForActionCellAt(row: Int, forActionSheet actionSheet: SimpleActionSheet) -> CGFloat {
        return 44
    }
    
    func actionCellAt(row: Int, forActionSheet actionSheet: SimpleActionSheet) -> UITableViewCell {
        fatalError("Error: method actionCellAt(_:forActionSheet:) not implemented.")
    }
    
    func cancellingButtonFor(actionSheet: SimpleActionSheet) -> UIButton? {
        return nil
    }
}

// MARK: - SimpleActionSheetDelegate
public protocol SimpleActionSheetDelegate: class {
    func didSelectActionCellAt(row: Int, forActionSheet actionSheet: SimpleActionSheet)
    
    func didTapCancellingButton()
}

extension SimpleActionSheetDelegate {
    func didSelectActionCellAt(row: Int, forActionSheet actionSheet: SimpleActionSheet) {}
    
    func didTapCancellingButton() {}
}

// MARK: - SimpleActionSheet
public class SimpleActionSheet: UIViewController {
    // MARK: - Properties
    public private(set) lazy var tableView: UITableView! = {
        let tableView = UITableView(frame: .zero, style: .Plain)
        
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        tableView.scrollEnabled = false
        
        tableView.separatorInset = UIEdgeInsetsZero
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 44
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 1))
        
        return tableView
    }()
    
    public weak var dataSource: SimpleActionSheetDataSource?
    public weak var delegate: SimpleActionSheetDelegate?
    
    private var isFirstAppear = true
    
    private var cancellingButton: UIButton? {
        didSet {
            if let button = cancellingButton {
                button.layer.cornerRadius = tableView.layer.cornerRadius
                button.clipsToBounds = true
                
                button.addTarget(self, action: #selector(self.cancellingButtonTapped), forControlEvents: .TouchUpInside)
            }
        }
    }
    
    private lazy var containerView: UIView! = {
        let containerView = UIView()
        
        return containerView
    }()
    
    // MARK: - Init & Deinit
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .OverCurrentContext
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .OverCurrentContext
    }
    
    // MARK: - VC Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        showActionSheet()
    }
    
    // MARK: - UI Config
    private func setupUI() {
        view.backgroundColor = UIColor.clearColor()
        view.addSubview(containerView)
        
        do {
            containerView.addSubview(tableView)
            cancellingButton = dataSource?.cancellingButtonFor(self)
            
            if let cancellingButton = cancellingButton {
                tableView.snp_remakeConstraints { make in
                    make.left.equalTo(containerView).offset(10)
                    make.right.equalTo(containerView).offset(-10)
                    make.top.equalTo(containerView)
                    
                    var tableViewHeight: CGFloat = 0
                    if let numberOfCells = dataSource?.numberOfActionCellsFor(self) {
                        for row in 0..<numberOfCells {
                            tableViewHeight += dataSource?.heightForActionCellAt(row, forActionSheet: self) ?? 44
                        }
                    }
                    
                    make.height.equalTo(tableViewHeight)
                }
                
                containerView.addSubview(cancellingButton)
                
                cancellingButton.snp_remakeConstraints { make in
                    make.left.equalTo(tableView)
                    make.right.equalTo(tableView)
                    make.top.equalTo(tableView.snp_bottom).offset(7)
                    make.bottom.equalTo(containerView)
                }
            } else {
                tableView.snp_remakeConstraints { make in
                    make.edges.equalTo(containerView)
                    
                    var tableViewHeight: CGFloat = 0
                    if let numberOfCells = dataSource?.numberOfActionCellsFor(self) {
                        for row in 0..<numberOfCells {
                            tableViewHeight += dataSource?.heightForActionCellAt(row, forActionSheet: self) ?? 44
                        }
                    }
                    
                    make.height.equalTo(tableViewHeight)
                }
            }
        }
        
        containerView.snp_remakeConstraints { make in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(view.snp_bottom)
        }
    }
    
    // MARK: - Action Handlers
    func cancellingButtonTapped() {
        dismissActionSheet { 
            self.dismissViewControllerAnimated(false) {
                self.delegate?.didTapCancellingButton()
            }
        }
    }
    
    // MAKR: - UI Animation
    private func showActionSheet() {
        guard isFirstAppear else {
            return
        }
        
        isFirstAppear = false
        
        UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseInOut], animations: {
            self.containerView.snp_remakeConstraints { make in
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.bottom.equalTo(self.view).offset(-9)
            }
            
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
            
            }, completion: nil)
    }
    
    private func dismissActionSheet(completion: () -> Void) {
        UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseInOut], animations: {
            self.containerView.snp_remakeConstraints { make in
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.top.equalTo(self.view.snp_bottom)
            }
            
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clearColor()
            
            }, completion: { finished in
                completion()
        })
    }
}

// MARK: - UITableView DataSource
extension SimpleActionSheet: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfActionCellsFor(self) ?? 0
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataSource?.heightForActionCellAt(indexPath.row, forActionSheet: self) ?? 44
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = dataSource!.actionCellAt(indexPath.row, forActionSheet: self)
        
        return dataSource!.actionCellAt(indexPath.row, forActionSheet: self)
    }
}

// MARK: - UITableView Delegate
extension SimpleActionSheet: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        dismissActionSheet {
            self.dismissViewControllerAnimated(false) {
                self.delegate?.didSelectActionCellAt(indexPath.row, forActionSheet: self)
            }
        }
    }
}