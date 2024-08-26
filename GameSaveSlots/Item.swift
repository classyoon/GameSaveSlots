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
class GameSave {
    var score : Int
    var name : String
    var user : User?
    init(score: Int = 0, user: User? = nil, name : String = "") {
        self.score = score
        self.user = user
        self.name = name
    }
    static let examples : [GameSave] = [
        .init(score: 10, name: "My best attempt"),
        .init(score: 5, name: "idk what this"),
        .init(score: 0, name: "adsfadsfdsa")
    ]
}

@Model
final class User {
    var name : String
    var games : [GameSave]
    
    init(name: String = "", games: [GameSave] = [])  {
        self.name = name
        self.games = games
    }
    static let examples : [User] = [.init(name: "Steve"), .init(name: "Jobs")]
}


struct GameListView : View {
    @State var isShowingAddSheet = false
    @Environment(\.modelContext) private var modelContext
    @Bindable var user : User
    @Query private var games : [GameSave]
    
    var body: some View {
        
        List {
            ForEach(user.games){ game in
                NavigationLink {
                    GameEditView(game: game)
                        .navigationTitle("\(game.name)")
                } label: {
                    GameSlotView(game: game)
                }
                
                
            }
            Button("New Game"){
                isShowingAddSheet = true
            }
            .sheet(isPresented: $isShowingAddSheet, content: {
                NavigationStack{
                    GameAddView(user: user)
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
                Text("\(game.name), score : \(game.score)")
            }
        }
    }
    struct GameAddView : View {
        @State private var newGame = GameSave()
        @Bindable var user : User
        @Environment(\.dismiss) var dismiss
        @Environment(\.modelContext) var modelContext
        
        var body: some View {
            HStack{
                GameEditView(game: newGame)
                    .toolbar{
                        Button(action: {
                           // modelContext.insert(newGame)
                            user.games.append(newGame)
                            dismiss()
                        }, label: {
                            Text("Save Game")
                        })
                    }
            }
        }
    }
    struct GameEditView : View {
        @Bindable var game : GameSave
        var body: some View {
            Form{
                HStack{
                    TextField("name : \(game.name)", text: $game.name)
                    Text("Score : \(game.score)")
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


struct UserListView : View {
    @Environment(\.modelContext) var modelContext
    @Query private var users : [User]
    @State private var showingSheet : Bool = false
    
    var body: some View {
        List {
            ForEach(users){ user in
                NavigationLink {
                    UserEditView(user: user)
                } label: {
                    Text(user.name)
                }

            }
        }
        
        .navigationTitle("Choose User")
        .toolbar{
            Button(action: {
                showingSheet = true
            }, label: {
                Text("Register New User")
            })
        }
        .sheet(isPresented: $showingSheet, content: {
           
                UserAddView()
            
        })
        
    }
    struct UserAddView : View {
        @State private var user = User()
        @Environment(\.dismiss) var dismiss
        @Environment(\.modelContext) var modelContext
        
        var body: some View {
            NavigationStack{
                
                UserEditView(user: user)
                    .navigationTitle("Add User")
                    .toolbar(content: {
                        Button("Confirm"){
                            modelContext.insert(user)
                            dismiss()
                        }
                    })
                
            }
        }
    }
    struct UserEditView : View {
        @Bindable var user : User
        var body: some View {
            Form{
                Section("User"){
                    TextField("Enter Name", text: $user.name)
                }
                
                Section("Games"){
                    GameListView(user: user)
                }
            }
        }
    }
    
}



#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GameSave.self, configurations: config)
    GameSave.examples.forEach{ game in
        container.mainContext.insert(game)
    }
    User.examples.forEach{ user in
        container.mainContext.insert(user)
    }
    User.examples[0].games.append(GameSave.examples[0])
    User.examples[0].games.append(GameSave.examples[1])
    
    return NavigationStack{
        UserListView()
            .modelContainer(container)
    }
    
}
