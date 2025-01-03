//
//  TrailingActionsModifier.swift
//  TrailingActions
//
//  Created by Kostiantyn Kolosov on 20.12.2024.
//

// TODO: - Reverse auto action from overdrag
// TODO: - Gesture area
// TODO: - Appearance Manager

// FIXME: - end gesture animation smoothing


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
         actionWidth: CGFloat,
         viewConfig: SwipeActionsViewConfig,
         leadingContentIsPresented: Binding<Bool>,
         trailingContentIsPresented: Binding<Bool>) {
        let viewModel = SwipeActionsViewModel(trailingActions: trailingActions,
                                              leadingActions: leadingActions)

        let presenter = SwipeActionsPresenter(actionWidth: actionWidth,
                                              leadingSwipeIsUnlocked: !leadingActions.isEmpty,
                                              trailingSwipeIsUnlocked: !trailingActions.isEmpty,
                                              trailingViewWidth: CGFloat(trailingActions.count) * actionWidth,
                                              leadingViewWidth: CGFloat(leadingActions.count) * actionWidth)
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
                        Color.clear.onAppear { contentWidth = proxy.size.width } }
                }
                .offset(x: interactor.gestureState.offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in interactor.dragOnChanged(translation: value.translation.width) }
                        .onEnded { _ in interactor.dragEnded() }
                )
                .background(alignment: interactor.gestureState.swipeDirection.alignment) { swipeView }
                .overlay {
                    if interactor.gestureState.offset != 0 {
                        Button {
                            interactor.resetOffsetWithAnimation()
                        } label: {
                            Rectangle()
                                .opacity(.zero)
                                .offset(x: interactor.gestureState.offset)
                        }
                    }
                }
        }
        .clipped()
        .mask { content }
        .onChange(of: leadingContentIsPresented) { newValue in
            interactor.showLeadingContent(flag: leadingContentIsPresented)
        }
        .onChange(of: trailingContentIsPresented) { newValue in
            interactor.showTrailingContent(flag: trailingContentIsPresented)
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
                interactor.resetOffsetWithAnimation()
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
                interactor.resetOffsetWithAnimation()
            }
        }
    }
}
