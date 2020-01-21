//  ForumVC.swift
//  end-user-api-demo

import UIKit

var currentForum: Forum?
class ForumVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cellReuseIdentifier = "cell"
    @IBOutlet var tableView: UITableView!
    @IBOutlet var newIdeaTextField: UITextField!
    @IBOutlet var newIdeaSubmit: UIButton!
    @IBOutlet var navBar: UINavigationItem!
    
    var ideas: [Idea] = []
    
    func refresh() {
        UvApi.getForumIdeas(forumId: currentForum!.id) { data in
            self.ideas = data as! Array<Idea>
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.newIdeaTextField.text = ""
            }
        }
    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        if newIdeaTextField.text?.count == 0 {
            return
        }
        
        if !UvApi.isSignedIn() {
            UvApi.signIn(vc: self) {
                self.onSubmit(sender)
            }
            return
        }
        
        UvApi.postIdea(
            title: newIdeaTextField.text!,
            forumId: currentForum!.id
        ) { result in
            self.refresh()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        newIdeaTextField.placeholder = currentForum!.prompt
        navBar.title = currentForum?.name
        
        if tableView == nil {
            tableView = UITableView()
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        refresh()
    }

    // Number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ideas.count
    }

    // Create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!

        // Set the text from the data model
        cell.textLabel?.text = self.ideas[indexPath.row].title

        return cell
    }

    // Method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIdea = ideas[indexPath.row]
        self.performSegue(withIdentifier: "ShowIdeaDetailFromForum", sender: self)
    }

}
