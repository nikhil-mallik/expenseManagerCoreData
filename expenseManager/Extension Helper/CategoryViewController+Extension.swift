//
//  CategoryViewController+Extension.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 09/06/23.
//

import Foundation
import UIKit


extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let card = cardData[indexPath.row]
        
        cell.titleOutlet.text = card.titleOutlet
        cell.expAmtOutlet.text = "Total Expense: \(card.expAmtOutlet)"
        let difference = card.leftAmtOutlet - card.expAmtOutlet
        cell.leftAmtOutlet.text = "\(difference) left out of \(card.leftAmtOutlet)"
        
        // Set the image from data
        if let image = UIImage(data: card.iconImageView) {
            cell.iconImageView.contentMode = .scaleAspectFill
            cell.iconImageView.layer.cornerRadius = cell.iconImageView.bounds.size.width / 2
            cell.iconImageView.clipsToBounds = true
            cell.iconImageView.image = image
        } else {
            // Use a placeholder image if the data is invalid
            cell.iconImageView.image = ImageHelper.generatePlaceholderImage(text: card.titleOutlet)
        }
        
        cell.onDetail = { [weak self] in
            self?.detailAction(indexPath: indexPath)
        }
        return cell
    }
}


extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell
        selectedIndexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal,
                                      title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.handleEditAction(at: indexPath)
            completionHandler(true)
        }
        edit.backgroundColor = .systemBlue
        
        let delete = UIContextualAction(style: .normal,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteCategory(at: indexPath)
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [edit, delete])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

