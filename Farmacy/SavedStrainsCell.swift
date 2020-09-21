//
//  SavedStrainsCell.swift
//  WeedPanel
//
//  Created by Brad Booysen on 15/11/19.
//  Copyright © 2019 Booysenberry. All rights reserved.
//

import UIKit

class SavedStrainsCell: UITableViewCell {
    

    @IBOutlet weak var raceColourView: UIView!
    @IBOutlet weak var savedStrainName: UILabel!
    @IBOutlet weak var savedStrainAcronym: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
