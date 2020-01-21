//  IdeaDetailVC.swift
//  end-user-api-demo

import UIKit

var currentIdea: Idea?
class IdeaDetailVC: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var voteButton: UIButton!
    
    var voted: Bool?
    
    @IBAction func onVotePress(_ sender: Any) {
        if !UvApi.isSignedIn() {
            UvApi.signIn(vc: self) {
                self.onVotePress(sender)
            }
            return
        }
        
        if (voted ?? false) {
            UvApi.deleteVote(forumId: currentForum!.id, ideaId: currentIdea!.id) { idea in
                currentIdea = idea as? Idea
            }
        } else {
            UvApi.postVote(forumId: currentForum!.id, ideaId: currentIdea!.id) { idea in
                currentIdea = idea as? Idea
                self.updateData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.voteButton.setTitle("Vote", for: UIControl.State.normal)
        self.voteButton.setTitle("Voted", for: UIControl.State.selected)

        UvApi.getIdea(ideaId: currentIdea!.id) { result in
            currentIdea = result as? Idea
            self.updateData()
        }
    }
    
    func updateData() {
        DispatchQueue.main.async {
            self.titleLabel.text = currentIdea?.title
            self.textLabel.text = currentIdea?.text
            self.voted = currentIdea?.voted ?? false
            self.voteButton.isSelected = self.voted ?? false
        }
    }

}
