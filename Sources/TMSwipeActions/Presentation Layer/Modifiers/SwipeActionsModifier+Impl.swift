//
//  TrailingActionsModifier.swift
//  TrailingActions
//
//  Created by Kostiantyn Kolosov on 20.12.2024.
//

// TODO: - Gesture area
// TODO: - Appearance Manager
// TODO: - View as button in content view

import SwiftUI

public struct SwipeActionsModifier: ViewModifier {
    @Binding var trailingContentIsPresented: Bool
    @Binding var leadingContentIsPresented: Bool
    
    // MARK: - Private
    @StateObject private var interactor: SwipeActionsInteractor
    @StateObject private var presenter: SwipeActionsPresenter

    // Size
    @State private var contentWidth: CGFloat = 0
    @StateObject var gestureState: SwipeGestureState

    init(leadingActions: [SwipeAction],
         trailingActions: [SwipeAction],
         viewConfig: SwipeActionsViewConfig,
         leadingContentIsPresented: Binding<Bool>,
         trailingContentIsPresented: Binding<Bool>) {
        let viewModel = SwipeActionsViewModel(trailingActions: trailingActions,
                                              leadingActions: leadingActions)

        let presenter = SwipeActionsPresenter(actionWidth: viewConfig.actionWidth,
                                              leadingSwipeIsUnlocked: !leadingActions.isEmpty,
                                              trailingSwipeIsUnlocked: !trailingActions.isEmpty,
                                              trailingViewWidth: CGFloat(trailingActions.count) * viewConfig.actionWidth,
                                              leadingViewWidth: CGFloat(leadingActions.count) * viewConfig.actionWidth)
        let gestureState = SwipeGestureState()

        self._leadingContentIsPresented = leadingContentIsPresented
        self._trailingContentIsPresented = trailingContentIsPresented

        self._presenter = StateObject(wrappedValue: presenter)
        self._interactor = StateObject(wrappedValue: .init(
            viewModel: viewModel,
            presenter: presenter,
            gestureState: gestureState,
            viewConfig: viewConfig,
            isLeadingContentVisible: leadingContentIsPresented,
            isTrailingContentVisible: trailingContentIsPresented))
        self._gestureState = StateObject(wrappedValue: gestureState)
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .background {
                    GeometryReader { proxy in
                        // Fetching Container View Width
                        Color.clear.onAppear { self.contentWidth = proxy.size.width } }
                }
                .offset(x: interactor.gestureState.offset)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged { value in interactor.dragOnChanged(translation: value.translation.width) }
                        .onEnded { _ in interactor.dragEnded() }
                )
                .background(alignment: gestureState.swipeDirection.alignment) { swipeView }
                .overlay {
                    if gestureState.cachedOffset != 0 {
                        Button {
                            interactor.updateContent(visibility: .hidden)
                        } label: {
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in interactor.dragOnChanged(translation: value.translation.width) }
                                        .onEnded { _ in interactor.dragEnded() }
                                )
                        }
                        .offset(x: gestureState.cachedOffset)
                    }
                }
        }
        .clipped()
        .mask { content }
        .onChange(of: leadingContentIsPresented) { newValue in
            guard !interactor.ignoreContentChanging else { return }
            interactor.updateContent(visibility: leadingContentIsPresented ? .leading : .hidden)
        }
        .onChange(of: trailingContentIsPresented) { newValue in
            guard !interactor.ignoreContentChanging else { return }
            interactor.updateContent(visibility: trailingContentIsPresented ? .trailing : .hidden)
        }
    }

    // MARK: - Private
    @ViewBuilder
    private var swipeView: some View {
        switch interactor.gestureState.swipeDirection {
        case .trailing:
            ActionsView(viewConfig: $interactor.viewConfig,
                        actions: $interactor.viewModel.trailingActions,
                        offset: $interactor.gestureState.offset,
                        overdragged: $interactor.gestureState.overdragged,
                        containerWidth: $contentWidth,
                        swipeEdge: .trailing,
                        font: interactor.viewConfig.font,
                        actionWidth: presenter.actionWidth) {
                interactor.updateContent(visibility: .hidden)
            }
        case .leading:
            ActionsView(viewConfig: $interactor.viewConfig,
                        actions: $interactor.viewModel.leadingActions,
                        offset: $interactor.gestureState.offset,
                        overdragged: $interactor.gestureState.overdragged,
                        containerWidth: $contentWidth,
                        swipeEdge: .leading,
                        font: interactor.viewConfig.font,
                        actionWidth: presenter.actionWidth) {
                interactor.updateContent(visibility: .hidden)
            }
        }
    }
}
