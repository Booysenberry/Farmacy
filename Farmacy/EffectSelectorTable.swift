//
//  EffectSelectorTable.swift
//  WeedPanel
//
//  Created by Brad Booysen on 7/11/19.
//  Copyright © 2019 Booysenberry. All rights reserved.
//

import UIKit

class EffectSelectorTable: UITableViewController {
    
    var effects = ["Aroused","Creative","Energetic","Euphoric","Focused","Giggly","Happy","Hungry","Relaxed","Sleepy","Talkative","Tingly","Uplifted"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Explore Strains"

    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return effects.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "effectSelector", for: indexPath)
        
        cell.textLabel?.text = effects[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEffect = effects[indexPath.row]
        performSegue(withIdentifier: "showStrainsByEffect", sender: selectedEffect)
    }
    
    // Pass data to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let strainsVC = segue.destination as? StrainsViewController {
            if let selectedEffect = sender as? String {
                strainsVC.effect = selectedEffect
                strainsVC.dataSource = 2
            }
        }
    }
}
