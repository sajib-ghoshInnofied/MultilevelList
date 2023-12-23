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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func cellFillWithData(section: Section) {
        imgExpandCollapse.image = section.isOpened ? UIImage(named: "chevronDown") : UIImage(named: "chevronRight")
        imgExpandCollapseLeading.constant = CGFloat(section.level) * 8.0
        lblKey.text = section.key
        lblType.text = section.type
        if !section.isCollapsible {
            imgExpandCollapse.isHidden = true
            if let val = section.value as? Bool {
                (val == true) ? (lblCountItem.text = "YES") : (lblCountItem.text = "NO")
            }else if let val = section.value as? Int {
                lblCountItem.text = String(val)
            }else if let val = section.value as? Double {
                lblCountItem.text = String(val)
            }else{
                lblCountItem.text = section.value as? String
            }
        }else{
            imgExpandCollapse.isHidden = false
            lblCountItem.text = section.itemCount
        }
    }
}

