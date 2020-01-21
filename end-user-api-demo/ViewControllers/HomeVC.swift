//  HomeVC.swift
//  end-user-api-demo

import UIKit

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cellReuseIdentifier = "cell"
    @IBOutlet var tableView: UITableView!
    
    var forums: [Forum] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        UvApi.getForums() { data in
            self.forums = data as! Array<Forum>
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // Number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forums.count
    }

    // Create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!

        // Set the text from the data model
        cell.textLabel?.text = self.forums[indexPath.row].name

        return cell
    }

    // Method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentForum = forums[indexPath.row]
        self.performSegue(withIdentifier: "ShowForumFromHome", sender: self)
    }

}
