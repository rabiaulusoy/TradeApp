//
//  ViewController.swift
//  TradeApp
//
//  Created by rabia on 5.01.2022.
//

import UIKit
import Firebase

// MARK:- Containing ViewController
class MainViewController: UIViewController {
    
    var TransactionList : [Transaction] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myHeaderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getDataFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "buy" {
            let buySellVC = segue.destination as! BuySellVewControllerViewController
            buySellVC.transactionType = TransactionType.Buy
        }
        else if segue.identifier == "sell" {
            let buySellVC = segue.destination as! BuySellVewControllerViewController
            buySellVC.transactionType = TransactionType.Sell
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionCell
        cell.arrangeCell(transaction: TransactionList[indexPath.row])
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 10
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransactionList.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

extension MainViewController { // DB operations
    func getDataFromDatabase(){
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Transaction").addSnapshotListener { snapShot, error in
            if error != nil {
                Utils.makeAlert(vc: self, title: "Error", message: error?.localizedDescription ?? "Error occured when getting data from db!")
            }
            else {
                if snapShot?.isEmpty != true {
                    self.TransactionList.removeAll()
                    for documentData in snapShot!.documents {
                        guard let userEmail = documentData.get("userEmail") as? String else { return }
                        guard let fromUnit = documentData.get("fromUnit") as? String else { return }
                        guard let toUnit = documentData.get("toUnit") as? String else { return }
                        guard let fromAmount = documentData.get("fromAmount") as? String else { return }
                        guard let toAmount = documentData.get("toAmount") as? String else { return }
                        guard let currency = documentData.get("currency") as? String else { return }
                        guard let comissionFee = documentData.get("comissionFee") as? String else { return }
                        guard let profit = documentData.get("profit") as? Int else { return }
                        guard let transactionType = documentData.get("transactionType") as? String else { return }
                        guard let tranDate = documentData.get("tranDate") as? String else { return }
                        
                        self.TransactionList.append(Transaction(userEmail: userEmail, fromUnit: fromUnit, toUnit: toUnit, fromAmount: fromAmount, toAmount: toAmount, currency: currency, comissionFee: comissionFee, profit: profit, transactionType: transactionType, tranDate: tranDate))
                    }
                    
                    self.tableView.reloadData()
                }
               
            }
        }
    }
}
