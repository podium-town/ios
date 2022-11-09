//
//  HomeView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
  let store: Store<HomeState, HomeAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        ZStack {
          VStack(spacing: 0) {
            List {
              ForEach(1..<4) { post in
                Button {
                  viewStore.send(.presentThread(isPresented: true))
                } label: {
                  Post(post: Mocks.post)
                }
              }
              .listRowSeparator(.hidden)
              .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .refreshable {
              
            }
            
            VStack(spacing: 0) {
              Divider()
                .overlay(Color("ColorSeparator"))
              
              ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                  Button {
                    viewStore.send(.presentStories(isPresented: true))
                  } label: {
                    StoryAvatar()
                  }
                  
                  Button {
                    viewStore.send(.presentStories(isPresented: true))
                  } label: {
                    StoryAvatar()
                  }
                  
                  Button {
                    viewStore.send(.presentStories(isPresented: true))
                  } label: {
                    StoryAvatar()
                  }
                  
                  Button {
                    viewStore.send(.presentStories(isPresented: true))
                  } label: {
                    StoryAvatar()
                  }
                  
                  Button {
                    viewStore.send(.presentStories(isPresented: true))
                  } label: {
                    StoryAvatar()
                  }
                }
                .padding(.horizontal)
              }
              .padding(.top, 16)
              .padding(.bottom, 18)
            }
            .sheet(isPresented: viewStore.binding(
              get: \.isStoriesPresented,
              send: HomeAction.presentStories
            )) {
              IfLetStore(
                store.scope(
                  state: \.stories,
                  action: HomeAction.stories
                ),
                then: StoriesView.init(store:)
              )
            }
          }
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Image("more")
                .resizable()
                .frame(width: 18, height: 18)
                .scaledToFill()
            }
          }
          .onAppear {
            self.endTextEditing()
            viewStore.send(.initialize)
          }
          
          // Workaround for multiple NavigationLinks
          // https://github.com/pointfreeco/swift-composable-architecture/issues/393
          NavigationLink(destination: EmptyView()) {
            EmptyView()
          }
          
          WithViewStore(store.scope(state: \.isThreadPresented)) { viewStore in
            NavigationLink(
              destination: IfLetStore(
                store.scope(
                  state: \.thread,
                  action: HomeAction.thread
                ),
                then: { store in
                  ThreadView(store: store)
                }
              ),
              isActive: viewStore.binding(send: .presentThread(isPresented: false)),
              label: EmptyView.init
            )
          }
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(store: Store(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: AppEnvironment()
    ))
  }
}
