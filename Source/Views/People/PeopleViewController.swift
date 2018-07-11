//
//  PeopleViewController.swift
//  FriendTab
//
//  Created by Dylan Elliott on 7/7/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

class PeopleViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        
        let indices = 0 ..< TransactionManager.shared.people.count
        let indexPaths = indices.map({ IndexPath(row: $0, section: 0) })
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransactionManager.shared.people.count
    }
    
//    override func tableView(_ tableView: UITableView, textForRowAt indexPath: IndexPath) -> String {
//        let person = TransactionManager.shared.people[indexPath.row]
//        return "\(person.firstName!) \(person.lastName!)"
//    }
//
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = TransactionManager.shared.people[indexPath.row]
        showDetailForPerson(person)
        tableView.deselectRow(at: indexPath, animated: true)
    }
//
//    override func tableView(_ tableView: UITableView, accessoryForRowAt indexPath: IndexPath) -> UITableViewCell.AccessoryType {
//        return .disclosureIndicator
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: PersonTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell") as? PersonTableViewCell
            
        if cell == nil {
            cell = UINib(nibName: "PersonTableViewCell", bundle: nil).instantiate(withOwner: nil)[0] as? PersonTableViewCell
        }
        
        let person = TransactionManager.shared.people[indexPath.row]
        
        cell.nameLabel.text = "\(person.firstName!) \(person.lastName!)"
        
        let amount = person.transactionsArray.unsettledBalance
        cell.amountView.setAmount(amount)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func showDetailForPerson(_ person: Person) {
        guard let personViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? MainViewController else { return }
        personViewController.personId = person.objectID
        navigationController?.pushViewController(personViewController, animated: true)
    }
    
    func showAddPersonAlert(firstName: String?, lastName: String?) {
        let alert = UIAlertController(title: "Add Person", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { firstNameTextField in
            firstNameTextField.placeholder = "First name"
            firstNameTextField.text = firstName
        })
        
        alert.addTextField(configurationHandler: { lastNameTextField in
            lastNameTextField.placeholder = "Last name"
            lastNameTextField.text = lastName
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            guard let textFields = alert.textFields else { return }
            
            guard let newFirstName = textFields[0].text, newFirstName.count > 0 else {
                self.alert(title: "Error", message: "Please enter a valid first name", completion: {
                    self.present(alert, animated: true, completion: nil)
                })
                return
            }
            
            guard let newLastName = textFields[1].text, newLastName.count > 0 else {
                self.alert(title: "Error", message: "Please enter a last name", completion: {
                    self.present(alert, animated: true, completion: nil)
                })
                return
            }
            
            let newPerson = TransactionManager.shared.addPerson(firstName: newFirstName, lastName: newLastName)
            self.tableView.insertRows(at: [IndexPath(row: TransactionManager.shared.people.count - 1, section: 0)], with: .automatic)
            self.showDetailForPerson(newPerson)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped() {
        showAddPersonAlert(firstName: nil, lastName: nil)
    }
}
