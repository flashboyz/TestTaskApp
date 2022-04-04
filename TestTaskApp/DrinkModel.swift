//
//  DrinkModel.swift
//  TestTaskApp
//
//  Created by Константин Прокофьев on 02.04.2022.
//

import Foundation

struct Drink: Codable {
    let strDrink: String?
}

struct DrinksResponse: Codable {
    let drinks: [Drink]
}
