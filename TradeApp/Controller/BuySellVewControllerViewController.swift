//
//  AddFxVewControllerViewController.swift
//  TradeApp
//
//  Created by rabia on 6.01.2022.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class BuySellVewControllerViewController: UIViewController {
    
    var transactionType : TransactionType?
    var calculatedProfit : Int = 0
    var stockList : [Stock] = []
    var lastChangedField = LastChangedInput.FromUnit
    
    @IBOutlet weak var btnFrom: UIButton!
    @IBOutlet weak var btnTo: UIButton!
    @IBOutlet weak var txtFromUnit: UITextField!
    @IBOutlet weak var txtToUnit: UITextField!
    @IBOutlet weak var txtFromAmount: UITextField!
    @IBOutlet weak var txtToAmount: UITextField!
    @IBOutlet weak var txtCurrency: UITextField!
    @IBOutlet weak var txtComissionFee: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnBuySell: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtFromUnit.text = "TRY"
        
        self.tabBarController?.tabBar.isHidden = true
        
        if transactionType == TransactionType.Buy {
            btnBuySell.titleLabel?.text = "Buy"
        }
        else {
            btnBuySell.titleLabel?.text = "Sell"
            calculatedProfit = calculateProfit() // kaldırılabilir
        }
    }

    @IBAction func btnBuySellClicked(_ sender: Any) {
        saveTransactionHistory()
        updateStock()
    }
}

extension BuySellVewControllerViewController { // DB Operations
   
    func saveTransactionHistory(){
        let firestoreDatabase = Firestore.firestore()
        var firestoreDocument : DocumentReference? = nil
        let firestoreTransaction = ["userEmail": Auth.auth().currentUser!.email,
                                    "fromUnit" : txtFromUnit.text!,
                                    "toUnit": txtToUnit.text!,
                                    "fromAmount": txtFromAmount.text!,
                                    "toAmount": txtToAmount.text!,
                                    "currency": txtCurrency.text!,
                                    "comissionFee": txtComissionFee.text!,
                                    "profit": transactionType == TransactionType.Buy ? 0 : calculatedProfit,
                                    "transactionType": transactionType == TransactionType.Buy ? "buy" : "sell",
                                    "tranDate": datePicker.date.description,
                                    "systemDate": FieldValue.serverTimestamp()] as [String:Any]
        firestoreDocument = firestoreDatabase.collection("Transaction").addDocument(data: firestoreTransaction, completion: { error in
            if error != nil {
                Utils.makeAlert(vc: self, title: "Error", message: error?.localizedDescription ?? "Error occured at db operations!")
            }
            else {
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 1
            }
        })
    }
    
    func updateStock(){
        // Satın alınan veya Satılan varlık kaydını getir
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Stock").whereField("userEmail", isEqualTo: Auth.auth().currentUser!.email)
            .whereField("fromUnit", isEqualTo: txtFromUnit.text!)
            .whereField("toUnit", isEqualTo: txtToUnit.text!).getDocuments { querySnapShot, error in
                if error != nil {
                    Utils.makeAlert(vc: self, title: "Error", message: error?.localizedDescription ?? "Error occured when getting data from db!")
                }
                else {
                    if querySnapShot?.isEmpty != true { // önceden kayıt var
                        self.stockList.removeAll()
                        
                        for documentData in querySnapShot!.documents {
                            guard let userEmail = documentData.get("userEmail") as? String else { return }
                            guard let fromUnit = documentData.get("fromUnit") as? String else { return }
                            guard let toUnit = documentData.get("toUnit") as? String else { return }
                            guard let fromAmount = documentData.get("fromAmountTotal") as? Double else { return }
                            guard let toAmount = documentData.get("toAmountTotal") as? Double else { return }
                            guard let currency = documentData.get("currencyAverage") as? Double else { return }

                            self.stockList.append(Stock(userEmail: userEmail, fromUnit: fromUnit, toUnit: toUnit, fromAmountTotal: fromAmount, toAmountTotal: toAmount, currencyAverage: currency))
                            print("count of data: \(self.stockList.count)")
                        }
                        
                        if self.transactionType == TransactionType.Buy { // varlığa ekle - güncelle
                            guard let documentId = querySnapShot?.documents[0].documentID else { return }
                            
                            let fromAmountDb = self.stockList[0].fromAmountTotal
                            let fromAmountUi = Double(self.txtFromAmount.text!)
                            guard let fromAmountUiDouble = fromAmountUi as? Double else { return }
                            let fromAmountTotal = fromAmountDb + fromAmountUiDouble
                            
                            let toAmountDb = self.stockList[0].toAmountTotal
                            let toAmountUi =  Double(self.txtToAmount.text!)
                            guard let toAmountUiDouble = toAmountUi as? Double else { return }
                            let toAmountTotal = toAmountDb + toAmountUiDouble
                            
                            firestoreDatabase.collection("Stock").document(documentId).updateData(["fromAmountTotal": fromAmountTotal,
                                                                                                   "toAmountTotal": toAmountTotal,
                                                                                                   "currencyAverage" : fromAmountTotal/toAmountTotal])
                        }
                        else { // varlıktan çıkar - güncelle
                            guard let documentId = querySnapShot?.documents[0].documentID else { return }
                            
                            let fromAmountDb = self.stockList[0].fromAmountTotal
                            let fromAmountUi = Double(self.txtFromAmount.text!)
                            guard let fromAmountUiDouble = fromAmountUi as? Double else { return }
                            let fromAmountTotal = fromAmountDb - fromAmountUiDouble
                            
                            let toAmountDb = self.stockList[0].fromAmountTotal
                            let toAmountUi =  Double(self.txtFromAmount.text!)
                            guard let toAmountUiDouble = toAmountUi as? Double else { return }
                            let toAmountTotal = toAmountDb - toAmountUiDouble
                            
                            firestoreDatabase.collection("Stock").document(documentId).updateData(["fromAmountTotal": fromAmountTotal,
                                                                                                   "toAmountTotal": toAmountTotal,
                                                                                                   "currencyAverage" : fromAmountTotal/toAmountTotal])
                        }
                    }
                    else { // önceden kayıt yok eklemelisin
                        var firestoreDocument : DocumentReference? = nil
                        let firestoreStock = ["userEmail": Auth.auth().currentUser!.email,
                                              "fromUnit" : self.txtFromUnit.text!,
                                              "toUnit": self.txtToUnit.text!,
                                              "fromAmountTotal": Double(self.txtFromAmount.text!) ?? 0,
                                              "toAmountTotal": Double(self.txtToAmount.text!) ?? 0,
                                              "currencyAverage": Double(self.txtCurrency.text!) ?? 0,
                                              "systemDate": FieldValue.serverTimestamp()] as [String:Any]
                        firestoreDocument = firestoreDatabase.collection("Stock").addDocument(data: firestoreStock, completion: { error in
                            if error != nil {
                                Utils.makeAlert(vc: self, title: "Error", message: error?.localizedDescription ?? "Error occured at db operations!")
                            }
                            else {
                                self.navigationController?.popToRootViewController(animated: true)
                                self.tabBarController?.selectedIndex = 1
                            }
                        })
                    }
                }
            }
    }
    
    func calculateProfit() -> Int {
        // calculate profit
        return 0
    }
}

extension BuySellVewControllerViewController { // UITextFieldDelegate
    
    @IBAction func txtFromAmountChanged(_ sender: UITextField) {
        lastChangedField = LastChangedInput.FromUnit
        btnFrom.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
        btnTo.imageView?.image = UIImage(systemName: "circle")
        
        let fromAmount = Double(txtFromAmount.text!) ?? 0
        let currency = Double(txtCurrency.text!) ?? 0
        
        if currency != 0 {
            txtToAmount.text = "\(fromAmount / currency)"
        }
    }
    
    @IBAction func txtToAmountChanged(_ sender: UITextField) {
        lastChangedField = LastChangedInput.ToUnit
        btnTo.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
        btnFrom.imageView?.image = UIImage(systemName: "circle")
        
        let toAmount = Double(txtToAmount.text!) ?? 0
        let currency = Double(txtCurrency.text!) ?? 0
        
        if currency != 0 {
            txtFromAmount.text = "\(toAmount * currency)"
        }
    }
    
    @IBAction func txtCurrencyChanged(_ sender: UITextField) {
        var fromAmount = Double(txtFromAmount.text!) ?? 0
        var toAmount = Double(txtToAmount.text!) ?? 0
        let currency = Double(txtCurrency.text!) ?? 0

        if currency == 0 { return }
        
        if lastChangedField == LastChangedInput.FromUnit {
            toAmount = fromAmount / currency
            txtToAmount.text = "\(toAmount)"
        }
        else if lastChangedField == LastChangedInput.ToUnit {
            fromAmount = toAmount * currency
            txtFromAmount.text = "\(fromAmount)"
        }
    }
}
