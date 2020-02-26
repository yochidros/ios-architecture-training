//
//  Task.swift
//  TODO-MVC
//
//  Created by yochidros on 2020/02/26.
//  Copyright © 2020 yochidros. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

struct Task {
	var id: Int
	var name: String
	var desc: String
	var isCompleted: Bool
	
	init(id: Int, name: String, desc: String, isCompleted: Bool) {
		self.id = id
		self.name = name
		self.desc = desc
		self.isCompleted = isCompleted
	}
}

protocol TaskModelDelegate: class {
	func didAddTask(task: Task)
	func didDeleteTask(task: Task)
	func didCompletedTask(task: Task)
	func didFilteredTasks()
	func onError(error: TaskModelError)
}

enum TaskModelError: Error {
	case delete
	case complete
	case other
	
	var localizedDescription: String {
		switch self {
		case .delete:
			return "TASK ERROR: can't delete task cause to not find task"
		case .complete:
			return "TASK ERROR: can't add task cause to not find task"
		case .other:
			return "TASK ERROR: other"
		}
	}
}

class RealmTask : Object {
	@objc dynamic var id: Int = 1
	@objc dynamic var name: String = ""
	@objc dynamic var desc: String = ""
	@objc dynamic var isCompleted: Bool = false
	
	override static func primaryKey() -> String? {
		return "id"
	}
}

class TaskModel {
	var tasks: [Task]
	private var tempTasks: [Task] = []
	private var isFilter: Bool = false

	private weak var delegate: TaskModelDelegate?
	
	init(delegate: TaskModelDelegate?) {
		self.delegate = delegate
		self.tasks = []
		self.read()
	}
	
	private func read() {
		do {
			let realm = try Realm(configuration: .defaultConfiguration)
			let objects = realm.objects(RealmTask.self)
			let t: [Task] = objects.map { Task.init(id: $0.id, name: $0.name, desc: $0.desc, isCompleted: $0.isCompleted)}
			self.tasks = t
		} catch let e {
			print(e)
		}
	}
	
	private func save(task: Task) {
		do {
			let realm = try Realm(configuration: .defaultConfiguration)
			let object = RealmTask()
			object.id = task.id
			object.name = task.name
			object.desc = task.desc
			object.isCompleted = task.isCompleted
			realm.beginWrite()
			realm.add(object, update: .all)
			try realm.commitWrite()
		} catch let e {
			print(e)
		}
	}
	
	private func remove(task: Task) {
		do {
			let realm = try Realm(configuration: .defaultConfiguration)
			let objects = realm.objects(RealmTask.self).filter("id == %@", task.id)
			realm.beginWrite()
			realm.delete(objects)
			try realm.commitWrite()
		} catch let e {
			print(e)
		}
	}
	
	func add(name: String, desc: String) {
		let id = tasks.count + 1
		let task = Task.init(id: id, name: name, desc: desc, isCompleted: false)
		self.tasks.append(task)
		self.save(task: task)
		self.delegate?.didAddTask(task: task)
	}
	
	func delete(id: Int) {
		guard let taskId = tasks.firstIndex(where: { $0.id == id }) else {
			self.delegate?.onError(error: .delete)
			return
		}
		let task = tasks.remove(at: taskId)
		self.remove(task: task)
		self.delegate?.didDeleteTask(task: task)
	}
	
	func complete(id: Int, isCompleted: Bool) {
		guard let taskId = tasks.firstIndex(where: { $0.id == id }) else {
			self.delegate?.onError(error: .complete)
			return
		}
		self.tasks[taskId].isCompleted = isCompleted
		self.delegate?.didCompletedTask(task: tasks[taskId])
	}

	func filterCompleted(isCompleted: Bool) {
		if isCompleted {
			self.tempTasks = tasks
			self.tasks = self.tasks.filter { $0.isCompleted == isCompleted }
		} else {
			self.tasks = tempTasks
			tempTasks = []
		}

		delegate?.didFilteredTasks()
	}
}
