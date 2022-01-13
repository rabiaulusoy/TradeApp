//
//  TradeCell.swift
//  TradeApp
//
//  Created by rabia on 11.01.2022.
//

import UIKit

class TradeCell: UITableViewCell {

    @IBOutlet weak var lblToUnit: UILabel!
    @IBOutlet weak var lblToAmount: UILabel!
    @IBOutlet weak var lblFromAmount: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func arrangeCell(data: Any){
        if let transaction = data as? Transaction {
            lblToUnit.text = transaction.toUnit
            lblToAmount.text = transaction.toAmount
            lblFromAmount.text = transaction.fromAmount
            lblCurrency.text = transaction.currency
        }
        if let stock = data as? Stock {
            lblToUnit.text = stock.toUnit
            lblToAmount.text = "\(stock.toAmountTotal)"
            lblFromAmount.text = " \(stock.fromAmountTotal)"
            lblCurrency.text = "\(stock.currencyAverage)"
        }
    }

}
