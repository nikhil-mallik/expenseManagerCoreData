//
//  ParticularExpenseViewController+Extension.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 09/06/23.
//

import Foundation
import UIKit

// MARK: TableViewDataSource

extension ParticularExpenseViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ParticularExpenseTableViewCell
        let expense = expenses[indexPath.row]
        cell.expAmtOutlet.text = "Paid: \(expense.expenseAmount)"
        cell.descOutlet.text = expense.description
        
        // Set the image from data or use a placeholder image if the data is invalid
        if let image = UIImage(data: expense.imageURL) {
            cell.iconImageView.contentMode = .scaleAspectFill
            cell.iconImageView.clipsToBounds = true
            cell.iconImageView.image = image
        } else {
            cell.iconImageView.image = ImageHelper.generatePlaceholderImage(text: expense.description)
        }
        return cell
    }
}

// MARK: TableViewDelegate

extension ParticularExpenseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData() // Reload the table view to reflect the changes
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.editButtonTapped(at: indexPath)
            completionHandler(true)
        }
        edit.backgroundColor = .systemBlue
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteExpense(at: indexPath)
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [edit, delete])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

// MARK: UIImagePickerControllerDelegate

extension ParticularExpenseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil) // Handle the selected image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) // Handle cancellation
    }
}

