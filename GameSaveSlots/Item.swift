//
//  Item.swift
//  GameSaveSlots
//
//  Created by Conner Yoon on 8/26/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

@Model
class GameSave {
    var score : Int
    
    var user : String //Upgrade to user profile
    init(score: Int = 0, user: String = "No name") {
        self.score = score
        self.user = user
    }
    static let example : [GameSave] = [.init(score: 10, user: "John"), .init(score: 0, user: "Bill")]
}

struct GameSaveSlotsView : View {
    @State var isShowingAddSheet = false
    @Environment(\.modelContext) private var modelContext
    @Query private var games : [GameSave]
    
    var body: some View {
        
        List {
            ForEach(games){ game in
                NavigationLink {
                    GameEditView(game: game)
                        .navigationTitle("Editing \(game.user)'s game")
                } label: {
                    GameSlotView(game: game)
                }

               
            }
            Button("New Game"){
                isShowingAddSheet = true
            }
            .sheet(isPresented: $isShowingAddSheet, content: {
                NavigationStack{
                    GameAddView()
                        .navigationTitle("New Game")
                }
            })
          
        }
        .navigationTitle("Your games")
    }
    struct GameSlotView : View {
        let game : GameSave
        var body: some View {
            HStack{
                Text("name : \(game.user), score : \(game.score)")
            }
        }
    }
    struct GameAddView : View {
        @State private var newGame = GameSave()
        @Environment(\.dismiss) var dismiss
        @Environment(\.modelContext) var modelContext
        
        var body: some View {
            HStack{
                GameEditView(game: newGame)
                    .toolbar{
                        Button(action: {
                            modelContext.insert(newGame)
                            dismiss()
                        }, label: {
                            Text("Save Name")
                        })
                    }
            }
        }
    }
    struct GameEditView : View {
        @Bindable var game : GameSave
        var body: some View {
            VStack{
                HStack{
                    TextField("name : \(game.user)", text: $game.user)
                }
                NavigationLink {
                    GameView(game: game)
                } label: {
                    Text("Play")
                }

            }
        }
    }
   
}
struct GameView : View {
    @Bindable var game : GameSave
    var body: some View {
        VStack{
            Text("Score \(game.score)")
            Button("Increase score"){
                game.score+=1
            }
            Text("Yes this is the game")
            
        }
    }
}

    
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GameSave.self, configurations: config)
    GameSave.example .forEach{ game in
        container.mainContext.insert(game)
    }
    
    return NavigationStack{ GameSaveSlotsView().modelContainer(container)
    }
    
}
