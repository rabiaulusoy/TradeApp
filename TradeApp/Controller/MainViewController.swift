//
//  ViewController.swift
//  TradeApp
//
//  Created by rabia on 5.01.2022.
//

import UIKit
import Firebase
import FirebaseAuth

// MARK:- Containing ViewController
class MainViewController: UIViewController {
    
    var TransactionList : [Transaction] = []
    var StockList : [Stock] = []
    var selectedSegmentIndex = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myHeaderView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getDataFromDatabase()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
//            self.tableView.isHidden = false
            selectedSegmentIndex = 0
            getDataFromDatabase()
            break
        case 1:
//            self.tableView.isHidden = true
            selectedSegmentIndex = 1
            getDataFromDatabase()
            break
        default:
            break
        }
         
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
        
        if selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell", for: indexPath) as! TradeCell
            cell.arrangeCell(data: TransactionList[indexPath.row])
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 10
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell", for: indexPath) as! TradeCell
            cell.arrangeCell(data: StockList[indexPath.row])
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 10
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegmentIndex == 0 {
            return self.TransactionList.count
        }
        else {
            return self.StockList.count
        }
    }
}

extension MainViewController { // DB operations
    func getDataFromDatabase(){
        let firestoreDatabase = Firestore.firestore()
        
        if selectedSegmentIndex == 0 {
            firestoreDatabase.collection("Transaction")
                .whereField("userEmail", isEqualTo: Auth.auth().currentUser!.email)
                .addSnapshotListener { snapShot, error in
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
                                        // var comissionFee = "2"
                            guard let profit = documentData.get("profit") as? Int else { return }
                            guard let transactionType = documentData.get("transactionType") as? String else { return }
                            guard let tranDate = documentData.get("tranDate") as? Timestamp else { return }
                            
                            self.TransactionList.append(Transaction(userEmail: userEmail, fromUnit: fromUnit, toUnit: toUnit, fromAmount: fromAmount, toAmount: toAmount, currency: currency, comissionFee: comissionFee, profit: profit, transactionType: transactionType, tranDate: tranDate.dateValue()))
                        }
                        self.TransactionList.sort(by: {$0.tranDate > $1.tranDate} )
                        self.tableView.reloadData()
                    }
                   
                }
            }
        }
        else {
            firestoreDatabase.collection("Stock")
                .whereField("userEmail", isEqualTo: Auth.auth().currentUser!.email)
                .addSnapshotListener { snapShot, error in
                if error != nil {
                    Utils.makeAlert(vc: self, title: "Error", message: error?.localizedDescription ?? "Error occured when getting data from db!")
                }
                else {
                    if snapShot?.isEmpty != true {
                        self.StockList.removeAll()
                        for documentData in snapShot!.documents {
                            guard let userEmail = documentData.get("userEmail") as? String else { return }
                            guard let fromUnit = documentData.get("fromUnit") as? String else { return }
                            guard let toUnit = documentData.get("toUnit") as? String else { return }
                            guard let fromAmount = documentData.get("fromAmountTotal") as? Double else { return }
                            guard let toAmount = documentData.get("toAmountTotal") as? Double else { return }
                            guard let currency = documentData.get("currencyAverage") as? Double else { return }
                            
                            self.StockList.append(Stock(userEmail: userEmail, fromUnit: fromUnit, toUnit: toUnit, fromAmountTotal: fromAmount, toAmountTotal: toAmount, currencyAverage: currency))
                        }
                        
                        self.tableView.reloadData()
                    }
                   
                }
            }
        }
     
    }
}
