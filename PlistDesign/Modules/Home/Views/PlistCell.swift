//
//  PlistCell.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 23/12/23.
//

import UIKit

class PlistCell: UITableViewCell {
        
    @IBOutlet weak var imgExpandCollapse: UIImageView!
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblCountItem: UILabel!
    @IBOutlet weak var imgExpandCollapseLeading: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    func cellFillWithData(section: Section) {
        imgExpandCollapse.image = section.isOpened ? UIImage(named: "chevronDown") : UIImage(named: "chevronRight")
        imgExpandCollapseLeading.constant = CGFloat(section.level) * 8.0
        lblKey.text = section.key
        lblType.text = section.type
        if !section.isCollapsible {
            imgExpandCollapse.isHidden = true
            lblCountItem.text = section.valueString
        } else {
            imgExpandCollapse.isHidden = false
            lblCountItem.text = section.itemCount
        }
    }
}
