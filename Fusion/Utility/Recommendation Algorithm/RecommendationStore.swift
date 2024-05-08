//
//  RecommendationStore.swift
//  Fusion
//
//  Created by Cristina Berlinschi on 26/04/2024.
//
//  Inspired By: https://www.kodeco.com/34652639-building-a-recommendation-app-with-create-ml-in-swiftui

/*
 The recommendation store is responsible for training the recommendation algorithm based on a user's likes
 Everytime a user swipes the training data is updated
 */

import Foundation
import TabularData

#if canImport(CreateML)
import CreateML
#endif

final class RecommendationStore {
  private let queue = DispatchQueue(label: "com.recommendation-service.queue", qos: .userInitiated)

  func computeRecommendations(basedOn items: [FavoriteWrapper<User>]) async throws -> [User] {
    return try await withCheckedThrowingContinuation { continuation in
      queue.async {
        #if targetEnvironment(simulator)
        continuation.resume(throwing: NSError(domain: "Simulator Not Supported", code: -1))
        #else
        let trainingData = items.filter {
          $0.isFavorite != nil
        }

        let trainingDataFrame = self.dataFrame(for: trainingData)

        let testData = items
        let testDataFrame = self.dataFrame(for: testData)

        do {
          let regressor = try MLLinearRegressor(trainingData: trainingDataFrame, targetColumn: "favorite")

          let predictionsColumn = (try regressor.predictions(from: testDataFrame)).compactMap { value in
            value as? Double
          }

          let sorted = zip(testData, predictionsColumn)
            .sorted { lhs, rhs -> Bool in
              lhs.1 > rhs.1
            }
            .filter {
              $0.1 > 0
            }
            .prefix(10)

          print(sorted.map(\.1))

          let result = sorted.map(\.0.model)

          continuation.resume(returning: result)
        } catch {
          continuation.resume(throwing: error)
        }
        #endif
      }
    }
  }

    //In this function I included the businessField and location as part of the training data
  private func dataFrame(for data: [FavoriteWrapper<User>]) -> DataFrame {
    var dataFrame = DataFrame()

    dataFrame.append(
      column: Column(name: "businessField", contents: data.map(\.model.businessField.rawValue))
    )
      
      dataFrame.append(
        column: Column(name: "l", contents: data.map(\.model.l))
      )

//        dataFrame.append(
//          column: Column(name: "design", contents: data.map(\.model.design.rawValue))
//        )
//
//        dataFrame.append(
//          column: Column(name: "neck", contents: data.map(\.model.neck.rawValue))
//        )
//
//        dataFrame.append(
//          column: Column(name: "sleeve", contents: data.map(\.model.sleeve.rawValue))
//        )
//
        dataFrame.append(
          column: Column<Int>(
            name: "favorite",
            contents: data.map {
              if let isFavorite = $0.isFavorite {
                return isFavorite ? 1 : -1
              } else {
                return 0
              }
            }
          )
        )

    return dataFrame
  }
}
