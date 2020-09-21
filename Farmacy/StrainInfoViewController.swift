//
//  StrainInfoViewController.swift
//  WeedPanel
//
//  Created by Brad Booysen on 29/10/19.
//  Copyright © 2019 Booysenberry. All rights reserved.
//

import UIKit
import CoreData

class StrainInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentStrain: StrainData?
    var receivedStrain: SavedStrain?
    private let apiKey = valueForAPIKey(keyname: "YOUR_APPLICATION_KEY")
    var positiveEffects = [String]()
    var negativeEffects = [String]()
    var medicalEffects = [String]()
    var flavours = [String]()
    var isSaved = false
    var strainId: Int?
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var strainDescription: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var strainEffectsSelector: UISegmentedControl!
    @IBOutlet weak var strainAcronym: UILabel!
    @IBOutlet weak var imageStrainName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var strainRaceView: UIView!
    @IBOutlet weak var strainRaceName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSearchableId()
        checkSaveStatus()
        getStrainInfo()
        sortEffects()
        
        // Set random hero image
        let numberOfImages: UInt32 = 7
        let random = arc4random_uniform(numberOfImages)
        let imageName = "image_\(random)"
        imageView.image = UIImage(named: imageName)
        
        // Populate UI
        
        if currentStrain != nil {
            if let name = currentStrain?.name {
                if let race = currentStrain?.race {
                    
                    // Create acronym from strain name
                    var acronym = ""
                    name.enumerateSubstrings(in: name.startIndex..<name.endIndex, options: .byWords) { (substring, _, _, _) in
                        if let substring = substring { acronym += substring.prefix(1) }
                    }
                    
                    imageStrainName.text = name
                    strainAcronym.text = acronym
                    strainRaceName.text = race.rawValue
                }
            }
        } else {
            if let name = receivedStrain?.name {
                if let race = receivedStrain?.race {
                    
                    // Create acronym from strain name
                    var acronym = ""
                    name.enumerateSubstrings(in: name.startIndex..<name.endIndex, options: .byWords) { (substring, _, _, _) in
                        if let substring = substring { acronym += substring.prefix(1) }
                    }
                    
                    imageStrainName.text = name
                    strainAcronym.text = acronym
                    strainRaceName.text = race
                }
            }
        }
        
        // Style race view
        strainRaceView.layer.cornerRadius = 3
        
        if currentStrain == nil {
            
            if let race = receivedStrain?.race {
                
                if race == "indica" {
                    strainRaceView.backgroundColor = UIColor.systemPurple
                } else if race == "sativa" {
                    strainRaceView.backgroundColor = UIColor.systemRed
                } else {
                    strainRaceView.backgroundColor = UIColor.systemGreen
                }
            }
        } else {
            if let race = currentStrain?.race {
                
                if race == .indica {
                    strainRaceView.backgroundColor = UIColor.systemPurple
                } else if race == .sativa {
                    strainRaceView.backgroundColor = UIColor.systemRed
                } else {
                    strainRaceView.backgroundColor = UIColor.systemGreen
                }
            }
        }
    }
    
    
    // Creates an int which can be used in the api call
    func createSearchableId() {
        if currentStrain == nil {
            if let id = receivedStrain?.id {
                strainId = Int(id)
            }
        } else {
            if let id = currentStrain?.id {
                strainId = id
            }
        }
    }
    
    // MARK: - Sort effects into seperate arrays
    func sortEffects() {
        
        if let effects = currentStrain?.effects {
            if let flavour = currentStrain?.flavors {
                
                for effect in effects.positive {
                    positiveEffects.append(effect.rawValue)
                }
                
                for effect in effects.negative {
                    negativeEffects.append(effect.rawValue)
                }
                
                for effect in effects.medical {
                    medicalEffects.append(effect.rawValue)
                }
                for effect in flavour {
                    flavours.append(effect.rawValue)
                    
                }
            }
        }
    }
    
    // MARK: - Fetch Strain description from api
    func getStrainInfo() {
        
        if let id = strainId {
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let descURL = "http://strainapi.evanbusse.com/\(apiKey)/strains/data/desc/\(id)"
            let effectsUrl = "http://strainapi.evanbusse.com/\(apiKey)/strains/data/effects/\(id)"
            let flavoursUrl = "http://strainapi.evanbusse.com/\(apiKey)/strains/data/flavors/\(id)"
            
            if let encodedDescURL = URL(string: descURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!) {
                if let encodedEffectsURL = URL(string: effectsUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!) {
                    if let encodedFlavoursURL = URL(string: flavoursUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!) {
                        
                        //Get strain description
                        let task1 = session.dataTask(with: encodedDescURL) { data, response, error in
                            
                            // Check for errors
                            guard error == nil else {
                                print ("error: \(error!)")
                                return
                            }
                            // Check that data has been returned
                            guard let content = data else {
                                print("No data")
                                return
                            }
                            
                            do {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                
                                let strainDesc = try decoder.decode(StrainData.self, from: content)
                                
                                // Update strain description
                                DispatchQueue.main.async {
                                    
                                    if strainDesc.desc == nil {
                                        
                                        self.strainDescription.text = "No description available"
                                        self.readMoreButton.isHidden = true
                                        
                                    } else {
                                        
                                        if let description = strainDesc.desc {
                                            
                                            // Hide the 'read more' button if description is less than 3 lines
                                            if self.strainDescription.numberOfLines > 3 {
                                                self.readMoreButton.isHidden = true
                                                
                                            }
                                            
                                            self.strainDescription.text = description
                                            
                                        }
                                    }
                                }
                            } catch let err {
                                print("Desc Err", err)
                            }
                        }
                        
                        //Get effects
                        let task2 = session.dataTask(with: encodedEffectsURL) { data, response, error in
                            
                            // Check for errors
                            guard error == nil else {
                                print ("error: \(error!)")
                                return
                            }
                            // Check that data has been returned
                            guard let content = data else {
                                print("No data")
                                return
                            }
                            
                            do {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                
                                let straineffects = try decoder.decode(Effects.self, from: content)
                                
                                // Sort effects
                                for strain in straineffects.positive {
                                    self.positiveEffects.append(strain.rawValue)
                                }
                                
                                for strain in straineffects.negative {
                                    self.negativeEffects.append(strain.rawValue)
                                }
                                for strain in straineffects.medical {
                                    self.medicalEffects.append(strain.rawValue)
                                }
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                
                            } catch let err {
                                print("Effects Err", err)
                            }
                        }
                        
                        //Get flavours
                        let task3 = session.dataTask(with: encodedFlavoursURL) { data, response, error in
                            
                            // Check for errors
                            guard error == nil else {
                                print ("error: \(error!)")
                                return
                            }
                            // Check that data has been returned
                            guard let content = data else {
                                print("No data")
                                return
                            }
                            
                            do {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                
                                let fetchedFlavours = try decoder.decode(flavourSearch.self, from: content)
                                
                                for flavour in fetchedFlavours {
                                    self.flavours.append(flavour.rawValue)
                                }
                                
                            } catch let err {
                                print("Flavours Err", err)
                            }
                        }
                        // execute the HTTP request
                        task1.resume()
                        
                        if currentStrain?.effects == nil {
                            task2.resume()
                        }
                        
                        if currentStrain?.flavors == nil {
                            task3.resume()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Strain property tableview data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        if strainEffectsSelector.selectedSegmentIndex == 0 {
            rows = positiveEffects.count
        } else if strainEffectsSelector.selectedSegmentIndex == 1 {
            rows = medicalEffects.count
        } else if strainEffectsSelector.selectedSegmentIndex == 2 {
            rows = flavours.count
        } else if strainEffectsSelector.selectedSegmentIndex == 3 {
            rows = negativeEffects.count
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "strainPropertyCell", for: indexPath)
        
        if strainEffectsSelector.selectedSegmentIndex == 0 {
            cell.textLabel?.text = positiveEffects[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = "Find more"
            
        } else if strainEffectsSelector.selectedSegmentIndex == 1 {
            cell.textLabel?.text = medicalEffects[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = "Find more"
            
        } else if strainEffectsSelector.selectedSegmentIndex == 2 {
            cell.textLabel?.text = flavours[indexPath.row]
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.detailTextLabel?.text = .none
            
        } else if strainEffectsSelector.selectedSegmentIndex == 3{
            cell.textLabel?.text = negativeEffects[indexPath.row]
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.detailTextLabel?.text = .none
            
        }
        return cell
    }
    
    // MARK: - Save button tapped
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        if isSaved == false {
            saveToCoreData()
            saveButton.image = UIImage(systemName: "bookmark.fill")
            isSaved = true
            
        } else {
            saveButton.image = UIImage(systemName: "bookmark")
            deletFromCoreData()
        }
    }
    
    // Delete from core data
    func deletFromCoreData() {
        
        if let id = strainId {
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedStrain")
                let predicate = NSPredicate(format: "id == \(String(describing: id))")
                request.predicate = predicate
                
                if let result = try? context.fetch(request) {
                    for object in result {
                        context.delete(object as! NSManagedObject)
                    }
                }
            }
        }
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
    // Save to core data
    func saveToCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            let strain = SavedStrain(context: context)
            
            strain.name = currentStrain?.name
            let race = currentStrain?.race
            
            if race == .indica {
                strain.race = "indica"
            } else if race == .hybrid {
                strain.race = "hybrid"
            } else if race == .sativa {
                strain.race = "sativa"
            }
            
            if let id = currentStrain?.id {
                strain.id = Float(id)
            }
            // Save to core data
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        }
    }
    
    // Handle taps on effects
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch strainEffectsSelector.selectedSegmentIndex {
        case 0:
            let selectedEffect = positiveEffects[indexPath.row]
            performSegue(withIdentifier: "showStrainsByEffect", sender: selectedEffect)
            
        case 1:
            let selectedEffect = medicalEffects[indexPath.row]
            performSegue(withIdentifier: "showStrainsByEffect", sender: selectedEffect)
            
        default:
            break
        }
    }
    
    // Pass data to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let strainsVC = segue.destination as? StrainsViewController {
            if let selectedEffect = sender as? String {
                strainsVC.effect = selectedEffect
                
                switch strainEffectsSelector.selectedSegmentIndex {
                case 0:
                    strainsVC.dataSource = 2
                    
                case 1:
                    strainsVC.dataSource = 3
                    
                case 3:
                    strainsVC.dataSource = 2
                    
                default:
                    break
                }
            }
        }
    }
    
    @IBAction func effectSelectorTapped(_ sender: Any) {
        
        tableView.reloadData()
        
    }
    
    // MARK: - Read more/less button action
    @IBAction func readMoreButtonTapped(_ sender: UIButton) {
        sender.tag += 1
        
        if sender.tag > 2 { sender.tag = 1 }
        
        switch sender.tag {
        case 1:
            strainDescription.numberOfLines = 0
            strainDescription.lineBreakMode = .byWordWrapping
            readMoreButton.setTitle("Read Less", for: .normal)
            
        case 2:
            strainDescription.numberOfLines = 3
            strainDescription.lineBreakMode = .byTruncatingTail
            readMoreButton.setTitle("Read More", for: .normal)
            
        default: break
            
        }
    }
    
    // MARK: - Check if strain has already been saved
    func checkSaveStatus() {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            if let id = strainId {
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedStrain")
                let predicate = NSPredicate(format: "id == \(String(describing: id))")
                request.predicate = predicate
                request.fetchLimit = 1
                
                do{
                    let count = try context.count(for: request)
                    if(count == 0){
                        // no matching object
                        saveButton.image = UIImage(systemName: "bookmark")
                        
                    }
                    else{
                        // at least one matching object exists
                        isSaved = true
                        saveButton.image = UIImage(systemName: "bookmark.fill")
                    }
                }
                catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
            }
        }
    }
}
