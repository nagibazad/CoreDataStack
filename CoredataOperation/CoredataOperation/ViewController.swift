//
//  ViewController.swift
//  CoredataOperation
//
//  Created by Nagib Azad on 21/12/18.
//  Copyright © 2018 Nagib Bin Azad. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var books: [Book] = [Book]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBookBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBookButtonPressed))
        self.navigationItem.rightBarButtonItem = addBookBarButton
        let deleteAllBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAllButtonPressed))
        let readAllBarButton = UIBarButtonItem(title: "Mark Read", style: .done, target: self, action: #selector(markAllReadButtonPressed))
        self.navigationItem.leftBarButtonItems = [deleteAllBarButton,UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),readAllBarButton]

        self.loadData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @objc func addBookButtonPressed() -> Void {
        let actionSheet = UIAlertController(title: "Choose", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "1 Book", style: .default, handler: { (action) in
            self.insertBook {
                self.loadData {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "10000 Books", style: .default, handler: { (action) in
            self.bookBatchInsert {
                self.loadData {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func deleteAllButtonPressed() -> Void {
        self.bookBatchDelete {
            self.loadData {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    @objc func markAllReadButtonPressed() -> Void {
        self.bookBatchUpdate {
            self.loadData {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "BookCellIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "BookCellIdentifier")
        }
        cell!.textLabel?.text = books[indexPath.row].name
        cell!.detailTextLabel?.text = books[indexPath.row].isRead ? "Read" : "Unread"
        return cell!
    }
}

extension ViewController {
    func loadData(completion:@escaping()->()) -> Void {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
        CoreDataStack.sharedInstance.fetchObjectAsynchronusly(withFetchRequest: fetchRequest) {[weak self](result, error) in
            if let strongSelf = self, result?.count != nil {
                strongSelf.books.removeAll()
                if let bookArray = result as? [Book] {
                    strongSelf.books += bookArray
                }
            }
            completion()
        }
    }
    
    func insertBook(completion:@escaping()->()) -> Void {
        let privateContext = CoreDataStack.sharedInstance.privateManagedObjectContext()!
        let book = CoreDataStack.insertNewManagedObject(forEntityName: "Book", inManagedObjectContext: privateContext) as? Book
        book?.name = "Book_\(Date().timeIntervalSince1970)"
        book?.isRead = false
        CoreDataStack.sharedInstance.saveDataAsynchronusly(inManagedObjectContext: privateContext) { (success, error) in
            if success == true{
                print("Suceess")
            }
            completion()
        }
    }
    
    func bookBatchInsert(completion:@escaping()->()) -> Void {
        let privateBatchContext = CoreDataStack.sharedInstance.batchRequestManagedObjectContext()!
        for _ in 0 ..< 10000 {
            let book = CoreDataStack.insertNewManagedObject(forEntityName: "Book", inManagedObjectContext: privateBatchContext) as? Book
            book?.name = "Book_\(Date().timeIntervalSince1970)"
            book?.isRead = false
        }
        
        CoreDataStack.sharedInstance.saveDataAsynchronusly(inManagedObjectContext: privateBatchContext) { (success, error) in
            if success == true{
                print("Suceess")
            }
            completion()
        }
    }
    
    func bookBatchDelete(completion:@escaping()->()) -> Void {
        let privateBatchContext = CoreDataStack.sharedInstance.batchRequestManagedObjectContext()!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        CoreDataStack.sharedInstance.executeBatchDeleteAsynchronusly(request: batchDeleteRequest, managedObjectContext: privateBatchContext) { (success, error) in
            if success == true {
                print("Success")
            }
            completion()
        }
    }
    
    func bookBatchUpdate(completion:@escaping()->()) -> Void {
        let privateBatchContext = CoreDataStack.sharedInstance.batchRequestManagedObjectContext()!
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Book")
        batchUpdateRequest.predicate = NSPredicate(format: "isRead = \(false)")
        batchUpdateRequest.propertiesToUpdate = ["isRead" : true]
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        CoreDataStack.sharedInstance.executeBatchUpdateAsynchronusly(request: batchUpdateRequest, managedObjectContext: privateBatchContext) { (success, error) in
            if success == true {
                print("Success")
            }
            completion()
        }
    }
}
