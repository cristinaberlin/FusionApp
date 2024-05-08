//
//  CardView.swift
//  Fusion
//
//
//

/*
 The code here belongs to a library used to create swipeable cards https://github.com/dadalar/SwiftUI-CardStackView
 */

import SwiftUI
import Foundation

struct CardView<Direction, Content: View>: View {
  @Environment(\.cardStackConfiguration) private var configuration: CardStackConfiguration
  @State private var translation: CGSize = .zero

  private let direction: (Double) -> Direction?
  private let isOnTop: Bool
  @Binding var swipeAction: SwipeAction
  private let onSwipe: (Direction) -> Void
  private let content: (Direction?) -> Content
    
  init(
    direction: @escaping (Double) -> Direction?,
    isOnTop: Bool,
    swipeAction: Binding<SwipeAction>,
    onSwipe: @escaping (Direction) -> Void,
    @ViewBuilder content: @escaping (Direction?) -> Content
  ) {
    self.direction = direction
    self.isOnTop = isOnTop
    self.onSwipe = onSwipe
    self._swipeAction = swipeAction
    self.content = content
  }

  var body: some View {
    GeometryReader { geometry in
      self.content(self.swipeDirection(geometry))
        .offset(self.translation)
        .rotationEffect(self.rotation(geometry))
        .simultaneousGesture(self.isOnTop ? self.dragGesture(geometry) : nil)
    }
    .transition(transition)
    .onChange(of: swipeAction) { oldValue, newValue in
        print("did change \(newValue.isRight ? "right" : "left")")
        if newValue.isRight {
            let direction = direction(79.6)!
            withAnimation(self.configuration.animation) { self.onSwipe(direction) }
        } else {
            let direction = direction(279.9)!
            withAnimation(self.configuration.animation) { self.onSwipe(direction) }
        }
    }
  }

  private func dragGesture(_ geometry: GeometryProxy) -> some Gesture {
    DragGesture()
      .onChanged { value in
        self.translation = value.translation
      }
      .onEnded { value in
        self.translation = value.translation
        if let direction = self.swipeDirection(geometry) {
          withAnimation(self.configuration.animation) { self.onSwipe(direction) }
        } else {
          withAnimation { self.translation = .zero }
        }
      }
  }
    
  

  private var degree: Double {
    var degree = atan2(translation.width, -translation.height) * 180 / .pi
    if degree < 0 { degree += 360 }
    return Double(degree)
  }

  private func rotation(_ geometry: GeometryProxy) -> Angle {
    .degrees(
      Double(translation.width / geometry.size.width) * 25
    )
  }

  private func swipeDirection(_ geometry: GeometryProxy) -> Direction? {
    guard let direction = direction(degree) else { return nil }
    let threshold = min(geometry.size.width, geometry.size.height) * configuration.swipeThreshold
    let distance = hypot(translation.width, translation.height)
      if distance > threshold {
          print("degree to make swipe \(degree)")
      }
    return distance > threshold ? direction : nil
  }

  private var transition: AnyTransition {
    .asymmetric(
      insertion: .identity,  // No animation needed for insertion
      removal: .offset(x: translation.width * 2, y: translation.height * 2)  // Go out of screen when card removed
    )
  }
}

