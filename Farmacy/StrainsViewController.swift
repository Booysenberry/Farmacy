//
//  ExploreStrainsViewController.swift
//  WeedPanel
//
//  Created by Brad Booysen on 25/10/19.
//  Copyright © 2019 Booysenberry. All rights reserved.
//

import UIKit

class StrainsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterSelector: UISegmentedControl!
    
    let search = UISearchController(searchResultsController: nil)
    private let apiKey = valueForAPIKey(keyname: "YOUR_APPLICATION_KEY")
    
    var strains = [StrainData]()
    var allStrains = [StrainData]()
    var hybrids = [StrainData]()
    var indicas = [StrainData]()
    var sativas = [StrainData]()
    var searchedStrains = [StrainData]()
    var menuShowing = false
    
    var dataSource = 1
    var effect: String?
    
    
    // check if search bar is empty
    var isSearchBarEmpty: Bool {
        return search.searchBar.text?.isEmpty ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuShowing = false
        
        // Menu initial position
        menuLeadingConstraint.constant = -260
        
        // Menu border radius and colour
        menuView.layer.cornerRadius = 3
        menuView.layer.borderWidth = 1.5
        menuView.layer.borderColor = UIColor.systemGray3.cgColor
        
        
        if dataSource == 1 {
            getAllStrainData()
            title = "Explore Strains"
            
        } else if dataSource == 2 {
            getStrainsByEffects()
            if let effect = effect {
                title = "\(effect) Strains"
            }
            
        } else {
            getStrainsByEffects()
            if let effect = effect {
                title = "Strains for \(effect)"
            }
        }
        
        // Setup search bar
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        
        if dataSource == 1 {
            search.searchBar.placeholder = "Search for a strain"
        } else {
            if let effect = effect {
                search.searchBar.placeholder = "Search in \(effect) strains"
            }
        }
        
        navigationItem.searchController = search
        
        // Pull to refesh
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        collectionView.refreshControl?.addTarget(self, action:  #selector(handleRefresh), for: .valueChanged)
        
    }
    
    // Handle refresh
    @objc func handleRefresh() {
        
        if filterSelector.selectedSegmentIndex == 0 {
            getAllStrainData()
            collectionView.refreshControl?.endRefreshing()
        } else {
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Fetch strain data from api
    func getAllStrainData() {
        
        strains.removeAll()
        allStrains.removeAll()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "http://strainapi.evanbusse.com/\(apiKey)/strains/search/all")!
        let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15.0)
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
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
                
                let recievedData = try decoder.decode(Strain.self, from: content)
                
                for (key, value) in recievedData {
                    
                    if let id = value.id {
                        if let race = value.race {
                            if let effects = value.effects {
                                if let flavours = value.flavors{
                                    
                                    let name = key
                                    let strain = StrainData(name: name, id: id, race: race, flavors: flavours, effects: effects)
                                    self.strains.append(strain)
                                    self.allStrains.append(strain)
                                    
                                }
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.sortStrains()
                }
                
            } catch let err {
                print("Err", err)
            }
        }
        // execute the HTTP request
        task.resume()
    }
    
    // MARK: - Fetch effects data from api
    func getStrainsByEffects() {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        config.urlCache = URLCache.shared
        let stringUrl = "http://strainapi.evanbusse.com/\(apiKey)/strains/search/effect/\(effect!)"
        
        if let encodedEffectsUrl = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            
            let task = session.dataTask(with: encodedEffectsUrl) { data, response, error in
                
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
                    
                    let recievedData = try decoder.decode(EffectSearch.self, from: content)
                    
                    for strain in recievedData {
                        
                        if let name = strain.name {
                            if let id = strain.id {
                                if let race = strain.race {
                                    
                                    let strain = StrainData(name: name, id: id, race: race)
                                    self.strains.append(strain)
                                    self.allStrains.append(strain)
                                    
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.sortStrains()
                        
                    }
                } catch let err {
                    print("Err", err)
                }
            }
            // execute the HTTP request
            task.resume()
        }
    }
    
    
    // MARK: - Sort fetched data by race
    func sortStrains() {
        
        for strain in strains {
            
            if strain.race == .indica {
                indicas.append(strain)
            } else if strain.race == .sativa {
                sativas.append(strain)
            } else {
                hybrids.append(strain)
            }
        }
    }
    
    // MARK: - Changes datasource to race specific array
    @IBAction func filterButtonTapped(_ sender: Any) {
        
        switch filterSelector.selectedSegmentIndex {
        case 0:
            strains = allStrains
            collectionView.scrollToTop()
        case 1:
            strains = hybrids
            collectionView.scrollToTop()
        case 2:
            strains = indicas
            collectionView.scrollToTop()
        case 3:
            strains = sativas
            collectionView.scrollToTop()
        default:
            break
        }
        collectionView.reloadData()
    }
    
    // MARK: - CollectionView Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return strains.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "strainInfoCell", for: indexPath as IndexPath) as! StrainInfoCell
        
        // Create acronym from strain name
        var acronym = ""
        strains[indexPath.row].name!.enumerateSubstrings(in: strains[indexPath.row].name!.startIndex..<strains[indexPath.row].name!.endIndex, options: .byWords) { (substring, _, _, _) in
            if let substring = substring { acronym += substring.prefix(1) }
        }
        
        cell.strainAcronym.text = acronym
        cell.strainNameLabel.text = strains[indexPath.row].name
        
        // Apply cell background colour based on strain race
        if strains[indexPath.row].race == .indica {
            cell.backgroundColor = UIColor.systemPurple
            
        } else if strains[indexPath.row].race == .sativa {
            cell.backgroundColor = UIColor.systemRed
            
        } else {
            cell.backgroundColor = UIColor.systemGreen
        }
        
        cell.layer.cornerRadius = 3
        cell.strainNameLabel.textColor = UIColor.white
        cell.strainAcronym.textColor = UIColor.white
        
        return cell
    }
    
    //MARK: - Set cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 3
        let spacingBetweenCells:CGFloat = 5
        
        let totalSpacing = (2 * spacingBetweenCells) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width * 1.5)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    //MARK: - Handle search text input
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        if isSearchBarEmpty {
            filterButtonTapped((Any).self)
            
        } else {
            strains = allStrains.filter { ($0.name?.localizedCaseInsensitiveContains("\(text)"))! }
            collectionView.reloadData()
        }
    }
    
    // Perform segue when user taps a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedStrain = strains[indexPath.row]
        performSegue(withIdentifier: "moveToStrainInfo", sender: selectedStrain)
    }
    
    // Pass data to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "moveToStrainInfo") {
            
            if let strainInfoVC = segue.destination as? StrainInfoViewController {
                if let selectedStrain = sender as? StrainData {
                    strainInfoVC.currentStrain = selectedStrain
                }
            }
        }
    }
    
    //MARK: - Toggle menu
    @IBAction func menuButtonTapped(_ sender: Any) {
        if menuShowing {
            menuLeadingConstraint.constant = -260
        } else {
            menuLeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            })
        }
        menuShowing = !menuShowing
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        menuLeadingConstraint.constant = -260
        menuShowing = false
    }
}

