//
//  MenuViewController.swift
//  WeedPanel
//
//  Created by Brad Booysen on 5/11/19.
//  Copyright © 2019 Booysenberry. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {
    
    @IBOutlet weak var strainsMenuItem: UILabel!
    @IBOutlet weak var effectsMenuItem: UILabel!
    @IBOutlet weak var medicalMenuItem: UILabel!
    @IBOutlet weak var savedStrains: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide empty cells
        tableView.tableFooterView = UIView()
        
        strainsMenuItem.text = "Strains"
        effectsMenuItem.text = "Effects"
        medicalMenuItem.text = "Medical"
        savedStrains.text = "Saved"
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "showStrains", sender: Any?.self)
            
        case 1:
            performSegue(withIdentifier: "showEffects", sender: Any?.self)
            
        case 2:
            performSegue(withIdentifier: "showMedical", sender: Any?.self)
            
        case 3:
            performSegue(withIdentifier: "showSaved", sender: Any?.self)
            
        default:
            break
        }
    }
    
    // Deselect table view cells after tap
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
}
