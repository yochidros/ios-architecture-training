//
//  ViewController.swift
//  TODO-MVC
//
//  Created by yochidros on 2020/02/26.
//  Copyright © 2020 yochidros. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView?
	@IBOutlet weak var switcher: UISwitch?
	
	private var model: TaskModel?
	private let tableViewCellName = "ToDoTableViewCell"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.prepare()
	}

	private func prepare() {
		self.model = TaskModel(delegate: self)
		self.tableView?.register(UINib(nibName: tableViewCellName, bundle: nil), forCellReuseIdentifier: tableViewCellName)
		self.tableView?.delegate = self
		self.tableView?.dataSource = self
	}

	@IBAction func onChangeValue(switcher: UISwitch) {
		model?.filterCompleted(isCompleted: switcher.isOn)
	}
	@IBAction func tappedAddButton(button: UIButton) {
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
		
		self.present(ac, animated: true, completion: nil)
	}
	
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
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

extension ViewController: TaskModelDelegate {
	func didFilteredTasks() {
		self.tableView?.reloadData()
	}
	
	func didAddTask(task: Task) {
		self.tableView?.beginUpdates()
		self.tableView?.insertRows(at: [IndexPath(row: task.id - 1, section: 0)], with: .bottom)
		self.tableView?.endUpdates()
	}
	
	func didDeleteTask(task: Task) {
		self.tableView?.deleteRows(at: [IndexPath(row: task.id - 1, section: 0)], with: .top)
	}
	
	func didCompletedTask(task: Task) {
		self.tableView?.reloadData()
	}
	
	func onError(error: TaskModelError) {
		print(error)
	}
	
}

