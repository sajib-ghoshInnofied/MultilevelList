//
//  PlistHeaderCell.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 23/12/23.
//

import UIKit

protocol PlistHeaderCellProtocol: AnyObject {
    func plistHeaderTappend(location: Int)
}

class PlistHeaderCell: UITableViewCell {

    weak var delegate: PlistHeaderCellProtocol?
    @IBOutlet weak var imgExpandCollapse: UIImageView!
    @IBOutlet weak var lblKey: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblCountItem: UILabel!
    @IBOutlet weak var imgExpandCollapseLeading: NSLayoutConstraint!
    var location = 0
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
        lblCountItem.text = section.itemCount
    }
    
    @IBAction func didTapOnHeaderButton(_ sender: UIButton) {
        delegate?.plistHeaderTappend(location: location)
    }
}
