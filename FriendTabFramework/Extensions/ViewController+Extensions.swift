//
//  ViewController+Extensions.swift
//  PlaygroundApp
//
//  Created by ELLIOTT, Dylan on 11/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

@IBDesignable
open class TextTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    lazy private(set) var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            view.topAnchor.constraint(equalTo: tableView.topAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
        ])
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let text = self.tableView(self.tableView, textForRowAt: indexPath)
        
        let detailText = self.tableView(self.tableView, detailTextForRowAt: indexPath)
        
        let cellStyle: UITableViewCell.CellStyle = {
            switch (text,detailText) {
            case (_, nil): return .default
            case (_, _): return .subtitle
            }
        }()
        
        let cellId: String = {
            switch cellStyle {
            case .subtitle: return "SubtitleCell"
            default: return "Cell"
            }
        }()
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: cellStyle, reuseIdentifier: cellId)
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, textForRowAt indexPath: IndexPath) -> String {
        return ""
    }
    
    open func tableView(_ tableView: UITableView, detailTextForRowAt indexPath: IndexPath) -> String? {
        return nil
    }
    
    
}

extension UIViewController {
    func alert(title: String?, message: String?, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?()}))
        self.present(alert, animated: true, completion: nil)
    }
}
