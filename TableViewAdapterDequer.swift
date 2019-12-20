//
//  UICollectionViewAdapter.swift
//  Teby
//
//  Created by Mohamed Hashem on 7/16/17.
//  Copyright © 2017 MAC. All rights reserved.
//

// swiftlint:disable opening_brace
// swiftlint:disable statement_position

import UIKit

class TableViewAdapterDequer: UITableView, UITableViewDelegate, UITableViewDataSource
{
    var dataArray: [Any] = []
    var dequeuers: [TableViewCellDequeuer] = []
    var isDequeuer = false
    var cellHeight: CGFloat = 50

    private var reuseIdentifier = "Cell"

    var autolayoutHeightConstraint: NSLayoutConstraint?

    var cellConfigurator: ((UITableViewCell, _ index: IndexPath) -> Void)?

    var emptyDataLabel: UIView!

    var emptyData: ((_ isEmpty: Bool) -> Void)? {
        didSet {
            emptyData != nil ? validateEmptyDataset() : ()
        }
    }

    /// cell xib name should match theclass name
    func setup<CellType: UITableViewCell>(cellset: String? = nil, data: [Any],
                                          cellHeight: CGFloat, alHeight: NSLayoutConstraint?,
                                          cellConfig: ((CellType, _ index: IndexPath) -> Void)?)
    {
        dataArray = data
        self.cellHeight = cellHeight
        autolayoutHeightConstraint = alHeight

        cellConfigurator = { (cell: UITableViewCell, _ index: IndexPath) in
            if let cellConfig = cellConfig, let cell = cell as? CellType {
                cellConfig(cell, index)
            }
            else
            { print("-- error: couldn't cast cell") }
        }

        let cell = cellset ?? String(describing: CellType.self)
        reuseIdentifier = cell
        register(UINib(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)

        delegate = self
        dataSource = self
    }

    func setupWithDequeuers(registering: [(nib: UINib?, identifier: String)], data: [TableViewCellDequeuer], alHeight: NSLayoutConstraint?) {
        isDequeuer = true
        registering.forEach { (regInfo) in
            register(regInfo.nib, forCellReuseIdentifier: regInfo.identifier)
        }
        dequeuers = data
        autolayoutHeightConstraint = alHeight

        delegate = self
        dataSource = self
    }

    func setEmptyDataSetView(emptyView: UIView) {
        emptyDataLabel = emptyView
        validateEmptyDataset()
    }

    func validateEmptyDataset() {
        let isEmpty = isDequeuer ? dequeuers.count == 0 : dataArray.count == 0
        emptyData?(isEmpty)
        if let emptyDataLabel = emptyDataLabel {
            emptyDataLabel.isHidden = !isEmpty
        }
    }
    /// emptyData---
    func setEmptyDataLabel(text: String, txtColor: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), fontSize: CGFloat = 15, font: UIFont)
    {
        let emptyLabel = UILabel()
        emptyLabel.textColor = txtColor
        emptyLabel.text = text
        emptyLabel.font.withSize(fontSize)
        emptyLabel.font = font

        setEmptyDataLabel(emptyView: emptyLabel)
    }

    private func setEmptyDataLabel(emptyView: UIView)
    {
        emptyDataLabel = emptyView
        addSubview(emptyDataLabel)
        emptyDataLabel.center = center
        emptyDataLabel.sizeToFit()
    }

    override func reloadData()
    {
        super.reloadData()
        validateEmptyDataset()
    }

    func reloadData(newData: [Any])
    {
        dataArray = newData
        reloadData()
    }

    func reloadData(newData: [TableViewCellDequeuer])
    {
        dequeuers = newData
        reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let emptyDataLabel = emptyDataLabel {
            emptyDataLabel.center = CGPoint(x: center.x, y: frame.height/2)
        }
    }
    ///---

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return isDequeuer ? dequeuers.count : dataArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return isDequeuer ? dequeuers[indexPath.row].cellHeight : cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if isDequeuer {
            return dequeuers[indexPath.row].dequeue(on: tableView, for: indexPath)
        } else {
            let cell = dequeueReusableCell(withIdentifier: reuseIdentifier)!
            cellConfigurator?(cell, indexPath)
            return cell
        }
    }

    func addItem(item: Any, animated: Bool)
    {
        dataArray.append(item)
        self.reloadData()
        stretch(animated: animated)
    }

    func addItem(item: TableViewCellDequeuer, animated: Bool)
    {
        dequeuers.append(item)
        self.reloadData()
        stretch(animated: animated)
    }

    func removeItem(at index: IndexPath, animated: Bool)
    {
        let _ = isDequeuer ? dequeuers.remove(at: index.row) : dataArray.remove(at: index.row)
        self.reloadData()
        stretch(animated: animated)
    }

    func stretch(animated: Bool, withMargen: CGFloat = 8)
    {
        if let autolayoutHeightConstraint = autolayoutHeightConstraint
        {
            let topView = superview?.superview
            if animated && topView != nil
            {
                UIView.animate(withDuration: 0.5, animations:
                    { [unowned self] in
                        autolayoutHeightConstraint.constant = self.contentSize.height + withMargen
                        topView?.layoutIfNeeded()
                })
            } else
            {
                autolayoutHeightConstraint.constant = contentSize.height + withMargen
            }

        }
    }

}

public protocol TableViewCellRegister {
    associatedtype CellType: UITableViewCell
    static var identifier: String { get }
    static var nib: UINib? { get }
}

public extension TableViewCellRegister {
    static func register(on tableView: UITableView) {
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }

    static func TableRegistrationData() -> (nib: UINib?, identifier: String) {
        return (nib, identifier)
    }

    func dequeue(on tableView: UITableView?, for indexPath: IndexPath) -> CellType {
        return tableView?.dequeueReusableCell(withIdentifier: Self.identifier,
                                              for: indexPath) as? CellType ?? CellType()
    }

    static var identifier: String {
        return "\(CellType.self)"
    }

    static var nib: UINib? {
        return UINib(nibName: "\(CellType.self)", bundle: Bundle(for: CellType.self))
    }

}

public protocol TableViewCellDequeuer {
    var cellHeight: CGFloat { get set }
    func dequeue(on tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell
}
