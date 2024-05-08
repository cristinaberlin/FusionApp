//
//  CardStack.swift
//  Fusion
//
//
//
/*
 The code here belongs to a library used to create swipeable cards https://github.com/dadalar/SwiftUI-CardStackView
 */
import Foundation
import SwiftUI

public struct SwipeAction: Hashable {
    let id = UUID()
    let isRight: Bool
}

public struct CardStack<Direction, ID: Hashable, Data: RandomAccessCollection, Content: View>: View
where Data.Index: Hashable {

  @Environment(\.cardStackConfiguration) private var configuration: CardStackConfiguration
  @State private var currentIndex: Data.Index
  private let direction: (Double) -> Direction?
  private let data: Data
  private let id: KeyPath<Data.Element, ID>
  private let onSwipe: (Data.Element, Direction) -> Void
  @Binding var swipeAction: SwipeAction
  private let content: (Data.Element, Direction?, Bool) -> Content

  public init(
    direction: @escaping (Double) -> Direction?,
    data: Data,
    id: KeyPath<Data.Element, ID>,
    swipeAction: Binding<SwipeAction>,
    onSwipe: @escaping (Data.Element, Direction) -> Void,
    @ViewBuilder content: @escaping (Data.Element, Direction?, Bool) -> Content
  ) {
    self.direction = direction
    self.data = data
    self.id = id
    self.onSwipe = onSwipe
    self.content = content
    self._swipeAction = swipeAction
    self._currentIndex = State<Data.Index>(initialValue: data.startIndex)
  }

  public var body: some View {
    ZStack {
      ForEach(data.indices.reversed(), id: \.self) { index -> AnyView in
        let relativeIndex = self.data.distance(from: self.currentIndex, to: index)
        if relativeIndex >= 0 && relativeIndex < self.configuration.maxVisibleCards {
          return AnyView(self.card(index: index, relativeIndex: relativeIndex))
        } else {
          return AnyView(EmptyView())
        }
      }
    }
  }

  private func card(index: Data.Index, relativeIndex: Int) -> some View {
    CardView(
      direction: direction,
      isOnTop: relativeIndex == 0,
      swipeAction: $swipeAction,
      onSwipe: { direction in
        self.onSwipe(self.data[index], direction)
        self.currentIndex = self.data.index(after: index)
      },
      content: { direction in
        self.content(self.data[index], direction, relativeIndex == 0)
          .offset(
            x: 0,
            y: CGFloat(relativeIndex) * self.configuration.cardOffset
          )
          .scaleEffect(
            1 - self.configuration.cardScale * CGFloat(relativeIndex),
            anchor: .bottom
          )
      }
    )
  }

}

extension CardStack where Data.Element: Identifiable, ID == Data.Element.ID {

  public init(
    direction: @escaping (Double) -> Direction?,
    data: Data,
    swipeAction: Binding<SwipeAction>,
    onSwipe: @escaping (Data.Element, Direction) -> Void,
    @ViewBuilder content: @escaping (Data.Element, Direction?, Bool) -> Content
  ) {
    self.init(
      direction: direction,
      data: data,
      id: \Data.Element.id,
      swipeAction: swipeAction,
      onSwipe: onSwipe,
      content: content
    )
  }

}

extension CardStack where Data.Element: Hashable, ID == Data.Element {

  public init(
    direction: @escaping (Double) -> Direction?,
    data: Data,
    swipeAction: Binding<SwipeAction>,
    onSwipe: @escaping (Data.Element, Direction) -> Void,
    @ViewBuilder content: @escaping (Data.Element, Direction?, Bool) -> Content
  ) {
    self.init(
      direction: direction,
      data: data,
      id: \Data.Element.self,
      swipeAction: swipeAction,
      onSwipe: onSwipe,
      content: content
    )
  }

}
