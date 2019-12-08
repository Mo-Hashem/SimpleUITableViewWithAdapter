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

class TableViewAdapter: UITableView, UITableViewDelegate, UITableViewDataSource
{
    var dataArray: [Any]!
    var cellHeight: CGFloat = 50

    private var reuseIdentifier = "Cell"

    var autolayoutHeightConstraint: NSLayoutConstraint?

    var cellConfigurator: ((UITableViewCell, _ index: IndexPath) -> Void)?

    var emptyDataLabel: UIView!

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

    func setEmptyDataSetView(emptyView: UIView) {
        emptyDataLabel = emptyView
        emptyDataLabel.isHidden = dataArray.count != 0
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
        if let emptyDataLabel = emptyDataLabel {
            emptyDataLabel.isHidden = dataArray.count != 0
        }
    }

    func reloadData(newData: [Any])
    {
        dataArray = newData
        reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let emptyDataLabel = emptyDataLabel {
            emptyDataLabel.center = CGPoint(x: center.x, y: height/2)
        }
    }
    ///---

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = dequeueReusableCell(withIdentifier: reuseIdentifier)!
        cellConfigurator?(cell, indexPath)
        return cell
    }

    func addItem(item: Any, animated: Bool)
    {
        dataArray.append(item)
        self.reloadData()
        stretch(animated: animated)
    }

    func removeItem(at index: IndexPath, animated: Bool)
    {
        dataArray.remove(at: index.row)
        self.reloadData()
        stretch(animated: animated)
    }

    func stretch(animated: Bool)
    {
        if let autolayoutHeightConstraint = autolayoutHeightConstraint
        {
            let topView = superview?.superview
            if animated && topView != nil
            {
                UIView.animate(withDuration: 0.5, animations:
                    { [unowned self] in
                        autolayoutHeightConstraint.constant = self.contentSize.height
                        topView?.layoutIfNeeded()
                })
            } else
            {
                autolayoutHeightConstraint.constant = contentSize.height
            }

        }
    }

}


class Client: UIViewController
{
    @IBOutlet weak var tableViewSample: TableViewAdapter!
    @IBOutlet weak var constCollectionHeight : NSLayoutConstraint!// constraint of the collection view Height / if you ont want animation ignore this line

    var dataArray: [String]? = ["hi", "wow"] // if there is no initial data, you can ignore this line


    override func viewDidLoad()
    {
        super.viewDidLoad()

        // empty data label that show when there is no data
        tableViewSample.setEmptyDataLabel(label: "No data")

        // suting up the collectionViewAdapter

        tableViewSample.setup(cell: "sampleCollectionCell", data: dataArray ?? [], cellHeight: 50,
                              alHeight: constCollectionHeight /* optional */ )
        { (cell, index) in
            (cell as! sampleTableViewCell).setup(data: self.tableViewSample.dataArray[index.row] as! String)
        }

    }

    @IBAction func addItemClicked(_ sender: Any)
    {

        self.tableViewSample.addItem(item: "hello", animated: true)

    }

    @IBAction func removeItemClicked(_ sender: Any)
    {
        self.tableViewSample.removeItem(at: IndexPath(row: 1, section: 0), animated: true)

    }

}
