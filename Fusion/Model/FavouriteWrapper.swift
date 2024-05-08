//
//  FavouriteWrapper.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 26/04/2024.
//
//  Inspired by: https://www.kodeco.com/34652639-building-a-recommendation-app-with-create-ml-in-swiftui

import Foundation

/*
 This model describes a whether a user was liked or not for the recommendation algorithm
 */
struct FavoriteWrapper<T> {
  let model: T
  var isFavorite: Bool?
}


