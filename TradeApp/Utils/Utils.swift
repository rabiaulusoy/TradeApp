//
//  Utils.swift
//  TradeApp
//
//  Created by rabia on 11.01.2022.
//

import Foundation
import UIKit

class Utils {
    static func makeAlert(vc: UIViewController, title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(btnOk)
        vc.present(alertVC, animated: true, completion: nil)
    }
}

enum TransactionType {
    case Buy
    case Sell
}
