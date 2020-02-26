//
//  ToDoTableViewCell.swift
//  TODO-MVC
//
//  Created by yochidros on 2020/02/26.
//  Copyright © 2020 yochidros. All rights reserved.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {

	static let ToDoTableViewCellHeight: CGFloat = 54.0
	@IBOutlet weak var nameLabel: UILabel?
	@IBOutlet weak var descLabel: UILabel?
	@IBOutlet weak var completedSwitch: UISwitch?
	
	private var handler: ((Bool) -> Void)? = nil
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
	
	func configure(task: Task, onCompleted: @escaping (Bool) -> Void) {
		self.nameLabel?.text = task.name
		self.descLabel?.text = task.desc
		self.completedSwitch?.isOn = task.isCompleted
		self.handler = onCompleted
	}
    
	@IBAction func onChangeValue(switcher: UISwitch) {
		self.handler?(switcher.isOn)
	}
}
