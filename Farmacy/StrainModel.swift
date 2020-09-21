//
//  StrainModel.swift
//  WeedPanel
//
//  Created by Brad Booysen on 30/10/19.
//  Copyright © 2019 Booysenberry. All rights reserved.
//


import Foundation

// MARK: - StrainData
struct StrainData: Codable {
    
    var name: String?
    var id: Int?
    let desc: String?
    var race: Race?
    var flavors: [Flavor]?
    let effects: Effects?

    init(name: String, id: Int, desc: String? = nil, race: Race, flavors: [Flavor]? = nil, effects: Effects? = nil) {
        self.name = name
        self.id = id
        self.desc = desc
        self.race = race
        self.flavors = flavors
        self.effects = effects
    }
}

// MARK: - Effects
struct Effects: Codable {
    let positive: [Positive]
    let negative: [Negative]
    let medical: [Medical]

    init(positive: [Positive], negative: [Negative], medical: [Medical]) {
        self.positive = positive
        self.negative = negative
        self.medical = medical
    }
}

enum Medical: String, Codable {
    case cramps = "Cramps"
    case depression = "Depression"
    case eyePressure = "Eye Pressure"
    case fatigue = "Fatigue"
    case headache = "Headache"
    case headaches = "Headaches"
    case inflammation = "Inflammation"
    case insomnia = "Insomnia"
    case lackOfAppetite = "Lack of Appetite"
    case muscleSpasms = "Muscle Spasms"
    case nausea = "Nausea"
    case pain = "Pain"
    case seizures = "Seizures"
    case spasticity = "Spasticity"
    case stress = "Stress"
}

enum Negative: String, Codable {
    case anxious = "Anxious"
    case dizzy = "Dizzy"
    case dryEyes = "Dry Eyes"
    case dryMouth = "Dry Mouth"
    case paranoid = "Paranoid"
}

enum Positive: String, Codable {
    case aroused = "Aroused"
    case creative = "Creative"
    case energetic = "Energetic"
    case euphoric = "Euphoric"
    case focused = "Focused"
    case giggly = "Giggly"
    case happy = "Happy"
    case hungry = "Hungry"
    case relaxed = "Relaxed"
    case sleepy = "Sleepy"
    case talkative = "Talkative"
    case tingly = "Tingly"
    case uplifted = "Uplifted"
}

enum Flavor: String, Codable {
    case ammonia = "Ammonia"
    case apple = "Apple"
    case apricot = "Apricot"
    case berry = "Berry"
    case blueCheese = "Blue Cheese"
    case blueberry = "Blueberry"
    case butter = "Butter"
    case cheese = "Cheese"
    case chemical = "Chemical"
    case chestnut = "Chestnut"
    case citrus = "Citrus"
    case coffee = "Coffee"
    case diesel = "Diesel"
    case earthy = "Earthy"
    case flowery = "Flowery"
    case grape = "Grape"
    case grapefruit = "Grapefruit"
    case honey = "Honey"
    case lavender = "Lavender"
    case lemon = "Lemon"
    case lime = "Lime"
    case mango = "Mango"
    case menthol = "Menthol"
    case mint = "Mint"
    case minty = "Minty"
    case nutty = "Nutty"
    case orange = "Orange"
    case peach = "Peach"
    case pear = "Pear"
    case pepper = "Pepper"
    case pine = "Pine"
    case pineapple = "Pineapple"
    case plum = "Plum"
    case pungent = "Pungent"
    case rose = "Rose"
    case sage = "Sage"
    case skunk = "Skunk"
    case spicyHerbal = "Spicy/Herbal"
    case strawberry = "Strawberry"
    case sweet = "Sweet"
    case tar = "Tar"
    case tea = "Tea"
    case tobacco = "Tobacco"
    case treeFruit = "Tree Fruit"
    case tropical = "Tropical"
    case vanilla = "Vanilla"
    case violet = "Violet"
    case woody = "Woody"
}

enum Race: String, Codable {
    case hybrid = "hybrid"
    case indica = "indica"
    case sativa = "sativa"
}

typealias Strain = [String: StrainData]
typealias EffectSearch = [StrainData]
typealias flavourSearch = [Flavor]
