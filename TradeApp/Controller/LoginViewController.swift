//
//  LoginViewController.swift
//  TradeApp
//
//  Created by rabia on 9.01.2022.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnSignInClicked(_ sender: Any) {
        if txtEmail.text != "" && txtPassword.text != "" {
            Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!) { authData, error in
                if error != nil {
                    Utils.makeAlert(vc: self, title: "Hata", message: error?.localizedDescription ?? "Giriş yapma işlemi başarısız!")
                }
                else {
                    self.performSegue(withIdentifier: "toMainVC", sender: nil)
                }
            }
        }
        else {
            Utils.makeAlert(vc: self, title: "Hata", message: "Kullanıcı adı ve şifre boş olamaz!")
        }
    }
    
    @IBAction func btnSignUpClicked(_ sender: Any) {
        if txtEmail.text != "" && txtPassword.text != "" {
            Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { authData, error in
                if error != nil {
                    Utils.makeAlert(vc: self, title: "Hata", message: error?.localizedDescription ?? "Kayıt işlemi başarısız!")
                }
                else {
                    self.performSegue(withIdentifier: "toMainVC", sender: nil)
                }
            }
        }
        else {
            Utils.makeAlert(vc: self, title: "Hata", message: "Kullanıcı adı ve şifre boş olamaz!")
        }
    }
}
