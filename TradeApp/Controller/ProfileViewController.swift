//
//  ProfileViewController.swift
//  TradeApp
//
//  Created by rabia on 9.01.2022.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnLogOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toLoginVC", sender: nil)
        }
        catch {
            print(error)
        }
        
    }
    
}
