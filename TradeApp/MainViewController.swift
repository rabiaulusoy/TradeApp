//
//  ViewController.swift
//  TradeApp
//
//  Created by rabia on 5.01.2022.
//

import UIKit

// MARK:- Containing ViewController
class ContainingViewController: UIViewController {
    
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
}

// MARK:- ScrollViewContaining Delegate

extension ContainingViewController: ScrollViewContainingDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // need to adjust the content offset to account for the content inset
        // negative because we are moving the header offscreen
        let newTopConstraintConstant = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        myHeaderViewTop.constant = min(0, max(-maxScrollAmount, newTopConstraintConstant))
        let isAtTop = myHeaderViewTop.constant == -maxScrollAmount

        // handle changes for collapsed state
        scrollViewScrolled(scrollView, didScrollToTop: isAtTop)
    }

    func scrollViewScrolled(_ scrollView: UIScrollView, didScrollToTop isAtTop:Bool) {
        //myHeaderView.backgroundColor = isAtTop ? UIColor.green : UIColor.systemPurple
    }
}

// MARK:- TableView Controller, ScrollViewContained

class TableViewController: UITableViewController,
                           ScrollViewContained {

    // used to connect the scrolling to the containing controller
    weak var scrollDelegate: ScrollViewContainingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // pass scroll events to the containing controller
        scrollDelegate?.scrollViewDidScroll(scrollView)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TVC
        cell.lblTitle.text = "USD"//"\(indexPath.row)"
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
        return 100
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK:- Protocols

protocol ScrollViewContainingDelegate: NSObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

protocol ScrollViewContained {
    var scrollDelegate: ScrollViewContainingDelegate? { get set }
}

// MARK:- TableView Cell
class TVC: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
}

