//
//  ViewController.swift
//  TODO-MVP
//
//  Created by yochidros on 2020/02/26.
//  Copyright © 2020 yochidros. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ToDoView {
	@IBOutlet weak var tableView: UITableView?
	@IBOutlet weak var switcher: UISwitch?
	
	var presenter: ToDoPresentation?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.prepare()
	}

	private func prepare() {
		presenter = ToDoPresenter(view: self, tableView: tableView)
	}

	@IBAction func onChangeValue(switcher: UISwitch) {
		presenter?.filter(isCompleted: switcher.isOn)
	}
	
	@IBAction func tappedAddButton(button: UIButton) {
		presenter?.tappedAddTask()
	}
	
	func showInputTaskView(view: UIAlertController) {
		self.present(view, animated: true, completion: nil)
	}
	
	func didAddTask(indexPaths: [IndexPath]) {
		self.tableView?.beginUpdates()
		self.tableView?.insertRows(at: indexPaths, with: .bottom)
		self.tableView?.endUpdates()
	}
	
	func didDeleteTask(indexPaths: [IndexPath]) {
		self.tableView?.deleteRows(at: indexPaths, with: .top)
	}
	
	func reloadData() {
		self.tableView?.reloadData()
	}
	

}
