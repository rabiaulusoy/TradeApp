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
    
    @IBOutlet weak var myHeaderView: UIView!
    @IBOutlet weak var myContainerView: UIView!
    @IBOutlet weak var myHeaderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var myHeaderViewTop: NSLayoutConstraint!
    @IBOutlet weak var myContainerViewTop: NSLayoutConstraint!
    
    // how far the header view gets scrolled offscreen
    var maxScrollAmount: CGFloat {
        let expandedHeight = myHeaderViewHeight.constant
        let collapsedHeight = myContainerViewTop.constant
        return expandedHeight - collapsedHeight
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scrollView = myContainerView.subviews.first as? UIScrollView {
            // adjust the scroll view's top inset to account for scrolling the header offscreen
            scrollView.contentInset = UIEdgeInsets(top: maxScrollAmount, left: 0, bottom: 0, right: 0)
        }

        if var scrollViewContained = children.first as? ScrollViewContained {
            scrollViewContained.scrollDelegate = self
        }
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

// MARK:- ScrollViewContaining Delegate

extension MainViewController: ScrollViewContainingDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // need to adjust the content offset to account for the content inset
        // negative because we are moving the header offscreen
        let newTopConstraintConstant = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        myHeaderViewTop.constant = min(0, max(-maxScrollAmount, newTopConstraintConstant))
        let isAtTop = myHeaderViewTop.constant == -maxScrollAmount
    }
}

// MARK:- TableView Controller, ScrollViewContained

class TableViewController: UITableViewController,
                           ScrollViewContained {

    var TransactionList : [Transaction] = []
    // used to connect the scrolling to the containing controller
    weak var scrollDelegate: ScrollViewContainingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromDatabase()
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // pass scroll events to the containing controller
        scrollDelegate?.scrollViewDidScroll(scrollView)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionCell
//        cell.setSelected(true, animated: true)
        cell.arrangeCell(transaction: TransactionList[indexPath.row])
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 10
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransactionList.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

extension TableViewController {
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

// MARK:- Protocols

protocol ScrollViewContainingDelegate: NSObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

protocol ScrollViewContained {
    var scrollDelegate: ScrollViewContainingDelegate? { get set }
}


struct Transaction {
    var userEmail : String
    var fromUnit : String
    var toUnit : String
    var fromAmount : String
    var toAmount : String
    var currency : String
    var comissionFee : String
    var profit : Int
    var transactionType : StringLiteralType
    var tranDate : String
}
