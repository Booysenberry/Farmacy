//
//  SavedStrainsTableView.swift
//  WeedPanel
//
//  Created by Brad Booysen on 15/11/19.
//  Copyright © 2019 Booysenberry. All rights reserved.
//

import UIKit

class SavedStrainsTableView: UITableViewController {
    
    var strainsCD = [SavedStrain]()
    
    override func viewDidAppear(_ animated: Bool) {
      
        title = "Saved"
        getSavedStrainData()
        navigationItem.rightBarButtonItem = editButtonItem
    
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return strainsCD.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedStrainCell") as! SavedStrainsCell
        
        if let name = strainsCD[indexPath.row].name {
            
            // Create acronym from strain name
            var acronym = ""
            name.enumerateSubstrings(in: name.startIndex..<name.endIndex, options: .byWords) { (substring, _, _, _) in
                if let substring = substring { acronym += substring.prefix(1) }
                cell.savedStrainAcronym.text = acronym
                cell.savedStrainName.text = name
            }
        }
        
        if strainsCD[indexPath.row].race == "indica" {
            cell.raceColourView.backgroundColor = .systemPurple
            
        } else if strainsCD[indexPath.row].race == "sativa" {
            cell.raceColourView.backgroundColor = .systemGreen
            
        } else {
            cell.raceColourView.backgroundColor = .systemRed
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStrain = strainsCD[indexPath.row]
        performSegue(withIdentifier: "showStrainInfo", sender: selectedStrain)
    }
    
    // Pass data to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showStrainInfo") {
            let vc = segue.destination as! StrainInfoViewController
            vc.receivedStrain = sender as? SavedStrain
        }
    }
    
    // Fetch saved strains from Core Data
    func getSavedStrainData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let strainsFromCD = try? context.fetch(SavedStrain.fetchRequest()) {
                if let strains = strainsFromCD as? [SavedStrain] {
                    strainsCD = strains
                    tableView.reloadData()
                    
                }
            }
        }
    }
    
    // Reorder strains
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let rowToMove = strainsCD[sourceIndexPath.row]
        strainsCD.remove(at: sourceIndexPath.row)
        strainsCD.insert(rowToMove, at: destinationIndexPath.row)
    }
    
    // Swipe to delete saved strain
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let strain = strainsCD[indexPath.row]
                context.delete(strain)
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                getSavedStrainData()
            }
        }
    }
    
}
