//
//  ToDoPresenter.swift
//  TODO-MVP
//
//  Created by yochidros on 2020/02/26.
//  Copyright © 2020 yochidros. All rights reserved.
//

import Foundation
import UIKit

protocol ToDoView {
	var presenter: ToDoPresentation? { get }
	
	func showInputTaskView(view: UIAlertController)
	func didAddTask(indexPaths: [IndexPath])
	func didDeleteTask(indexPaths: [IndexPath])
	func reloadData()
}

protocol ToDoPresentation {
	var view: ToDoView? { get }
	var tableDelegate: UITableViewDelegate? { get }
	var tableDataSource: UITableViewDataSource? { get }
	
	func tappedAddTask()
	func filter(isCompleted: Bool)
}

class ToDoPresenter:NSObject, ToDoPresentation {
	var view: ToDoView?
	
	private let tableViewCellName = "ToDoTableViewCell"
	var tableDelegate: UITableViewDelegate?
	var tableDataSource: UITableViewDataSource?
	
	private var model: TaskModel?

	init(view: ToDoView?, tableView: UITableView?) {
		super.init()
		self.view = view
		self.model = TaskModel(delegate: self)
		self.preapre(tableView: tableView)
	}
	
	private func preapre(tableView: UITableView?) {
		tableDelegate = self
		tableDataSource = self
		tableView?.delegate = tableDelegate
		tableView?.dataSource = tableDataSource
		tableView?.register(UINib(nibName: tableViewCellName, bundle: nil), forCellReuseIdentifier: tableViewCellName)
	}
	
	func tappedAddTask() {
		let ac = UIAlertController(title: "タスクを追加", message: nil, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default) { [weak self, ac] _ in
			
			guard let tfs = ac.textFields else { return }
			var name: String?
			var desc: String?
			
			for tf in tfs {
				switch tf.tag {
				case 1:
					name = tf.text
				case 2:
					desc = tf.text
				default:
					break
				}
			}
			
			guard let n = name, let d = desc else { return }
			
			self?.model?.add(name: n, desc: d)
		}
		let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
		ac.addTextField { (tf) in
			tf.placeholder = "タスク名"
			tf.tag = 1
		}
		ac.addTextField { (tf) in
			tf.placeholder = "備考"
			tf.tag = 2
		}
		ac.addAction(action)
		ac.addAction(cancel)
		self.view?.showInputTaskView(view: ac)
	}

	func filter(isCompleted: Bool) {
		model?.filterCompleted(isCompleted: isCompleted)
	}
}

extension ToDoPresenter: TaskModelDelegate {
	func didAddTask(task: Task) {
		self.view?.didAddTask(indexPaths: [IndexPath(row: task.id - 1, section: 0)])
	}
	
	func didDeleteTask(task: Task) {
		self.view?.didDeleteTask(indexPaths: [IndexPath(row: task.id - 1, section: 0)])
	}
	
	func didCompletedTask(task: Task) {
		self.view?.reloadData()
	}
	
	func didFilteredTasks() {
		self.view?.reloadData()
	}
	
	func onError(error: TaskModelError) {
		print(error)
	}

}

extension ToDoPresenter: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let tasks = self.model?.tasks, tasks.count != 0 else { return 0 }
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
		label.numberOfLines = 0
		label.font = .systemFont(ofSize: 14, weight: .light)
		label.text = tasks[indexPath.row].desc
		label.sizeToFit()
		return ToDoTableViewCell.ToDoTableViewCellHeight + label.bounds.size.height + 16
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			self.model?.delete(id: indexPath.row + 1)
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.model?.tasks.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellName, for: indexPath)
		
		if let c = cell as? ToDoTableViewCell, let task = self.model?.tasks[indexPath.row] {
			c.configure(task: task) { (isOn) in
				self.model?.complete(id: task.id, isCompleted: isOn)
			}
		}
		return cell
	}
}
