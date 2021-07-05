//
//  ContentView.swift
//  Shared
//
//  Created by Luke Drushell on 7/2/21.
//

import SwiftUI
import CoreData


struct ContentView: View {
    
    @State var newItem = true
    @State var showSheet = false
    @State var scaleNewButton = false
    @State var showNotes = false
    
    @State var currentIdea = Idea(name: "Loading", notes: "Loading", date: Date(), color: "red2", icon: "questionmark.app")
    @State var currentIdeaIndex = 0
    
    @State var ideasFile = Idea.loadFromFile()
    @State var ideas: [Idea] = []
    
    @State private var searchText = ""
    
    @State var newName: String = ""
    @State var newNotes: String = ""
    @State var newColor = "blue2"
    @State var newIcon = "house"
    
    var searchResults: [Idea] {
        if searchText.isEmpty {
            return ideas
        } else {
            return ideas.filter { $0.name.contains(searchText) }
        }
    }
        
    func getPosition(item: Idea) -> Int {
      for i in 0..<ideas.count {
            if (ideas[i].name == item.name){
                return i
            }
        }
        return 0
    }
    
    var formatter = DateFormatter()
    var formatter2 = DateFormatter()
        init() {
            UITextView.appearance().backgroundColor = .clear
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            formatter2.dateStyle = .short
            formatter2.timeStyle = .none
        }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    List {
                        ForEach(ideas, id: \.self, content: { idea in
                            HStack {
                                ZStack {
                                    Color.white
                                        .frame(width: 19, height: 19, alignment: .center)
                                        .cornerRadius(30)
                                    ZStack {
                                        Circle()
                                            .foregroundColor(Color("\(idea.color)"))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(uiImage: UIImage(systemName: "\(idea.icon)")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate) ?? UIImage(systemName: "questionmark.app")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))
                                            .resizable()
                                            .foregroundColor(.white)
                                            .scaledToFit()
                                            .padding(10)
                                            .cornerRadius(30)
                                    } .frame(width: 45, height: 45, alignment: .center)
                                }
                                Text(idea.name)
                                
                                Spacer()
                                
                                if #available(iOS 15.0, *) {
                                    Text(Date().formatted(date: .numeric, time: .omitted))
                                        .padding()
                                } else {
                                    // Fallback on earlier versions
                                    Text(formatter2.string(from: Date()))
                                        .padding()
                                }
                                
                            } .onTapGesture {
                                currentIdea = idea
                                newItem = false
                                showSheet = true
                                currentIdeaIndex = self.getPosition(item: idea)
                            }
                        })
                            .onDelete(perform: self.deleteItem)
                    }
                    //.searchable(text: $searchText, placement: .automatic)
                    Button {
                        //Bring up a sheet and set it to creating a new item mode
                        newItem = true
                        showSheet.toggle()
                        //----------------
                        
                        //Makess button smaller when tapped
                        scaleNewButton.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                            scaleNewButton.toggle()
                        })
                        //---------
                    } label: {
                        Text("New Item")
                            .fontWeight(.bold)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.15, alignment: .center)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                            .scaleEffect(scaleNewButton ? 0.95 : 1)
                    }
                } .navigationTitle("App Ideas")
            }
            .onAppear(perform: {
                if ideasFile.isEmpty == false {
                    ideas = ideasFile
                }
            })
        } .sheet(isPresented: $showSheet, onDismiss: {
            //code for saving
            //if everything filled out then save, if most isn't filled out then don't, if just one thing is missing then prompt user?
            
            if newItem == false {
                ideas.remove(at: currentIdeaIndex)
                ideas.insert(currentIdea, at: 0)
                Idea.saveToFile(ideas)
            } else {
                Idea.saveToFile(ideas)
            }
            
        }, content: {
            ScrollView(showsIndicators: false) {
                if newItem {
                    // Code for adding an idea
                    HStack {
                        ZStack {
                            Circle()
                                .foregroundColor(Color("\(newColor)"))
                                .frame(width: 40, height: 40)
                            
                            Image(uiImage: UIImage(systemName: "\(newIcon)")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate) ?? UIImage(systemName: "questionmark.app")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))
                                .resizable()
                                .foregroundColor(.white)
                                .scaledToFit()
                                .padding(10)
                                .cornerRadius(30)
                        } .frame(width: 45, height: 45, alignment: .center)
                        
                        Text(newName == "" ? "App Name" : newName)
                        Spacer()
                        if #available(iOS 15.0, *) {
                            Text(Date().formatted(date: .numeric, time: .omitted))
                                .padding()
                        } else {
                            // Fallback on earlier versions
                            Text(formatter2.string(from: Date()))
                                .padding()
                        }
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.2, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .padding(50)
                    
                    
                    TextField("Name", text: $newName)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.15, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    
                    TextField("Notes", text: $newNotes)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.15, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.bottom)
                    
                    //Colors
                    HStack {
                        HStack {
                            VStack {
                                Button {
                                    newColor = "red2"
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color("red2"))
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .cornerRadius(5)
                                }
                                Button {
                                    newColor = "orange2"
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color("orange2"))
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .cornerRadius(5)
                                }
                                Button {
                                    newColor = "yellow2"
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color("yellow2"))
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .cornerRadius(5)
                                }
                            }
                        
                            VStack {
                                Button {
                                    newColor = "pink2"
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color("pink2"))
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .cornerRadius(5)
                                }
                                Button {
                                    newColor = "lightblue2"
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color("lightblue2"))
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .cornerRadius(5)
                                }
                                Button {
                                    newColor = "blue2"
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color("blue2"))
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .cornerRadius(5)
                                }
                            }
                        
                            VStack {
                                Button {
                                    newColor = "purple2"
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color("purple2"))
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .cornerRadius(5)
                                }
                                Button {
                                    newColor = "darkblue2"
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color("darkblue2"))
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .cornerRadius(5)
                                }
                                Button {
                                    newColor = "green2"
                                } label: {
                                    Rectangle()
                                        .foregroundColor(Color("green2"))
                                        .frame(width: 35, height: 35, alignment: .center)
                                        .cornerRadius(5)
                                }
                            }
                    }
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(15)
                        
                        VStack {
                            HStack {
                                Button {
                                    newIcon = "house.fill"
                                } label: {
                                    Image(systemName: "house.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 5)
                                }
                                Button {
                                    newIcon = "car"
                                } label: {
                                    Image(systemName: "car")
                                        .resizable()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.leading, 5)
                                        .padding(.trailing, 5)
                                }
                                Button {
                                    newIcon = "highlighter"
                                } label: {
                                    Image(systemName: "highlighter")
                                        .resizable()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.leading, 5)
                                }
                            }
                            HStack {
                                Button {
                                    newIcon = "note.text"
                                } label: {
                                    Image(systemName: "note.text")
                                        .resizable()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 5)
                                }
                                Button {
                                    newIcon = "book.fill"
                                } label: {
                                    Image(systemName: "book.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.leading, 5)
                                        .padding(.trailing, 5)
                                }
                                Button {
                                    newIcon = "person.2.circle.fill"
                                } label: {
                                    Image(systemName: "person.2.circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.leading, 5)
                                }
                            }
                            HStack {
                                Button {
                                    newIcon = "icloud.circle.fill"
                                } label: {
                                    Image(systemName: "icloud.circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 5)
                                }
                                Button {
                                    newIcon = "speaker.wave.2.circle.fill"
                                } label: {
                                    Image(systemName: "speaker.wave.2.circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.leading, 5)
                                        .padding(.trailing, 5)
                                }
                                Button {
                                    newIcon = "desktopcomputer"
                                } label: {
                                    Image(systemName: "desktopcomputer")
                                        .resizable()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.leading, 5)
                                }
                            }
                            
                            HStack {
                                TextField("Custom Symbol", text: $newIcon)
                                    .frame(width: 130)
                                    .multilineTextAlignment(.center)
                                    .autocapitalization(UITextAutocapitalizationType.none)
                                    .foregroundColor(.white)
                            }
                            
                        }
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(15)
                    }
                    //----
                    .padding()
                    
                    Spacer()
                    
                    Button {
                        if newName != "" {
                            ideas.insert(Idea(name: newName, notes: newNotes, date: Date(), color: newColor, icon: newIcon), at: 0)
                        }
                        showSheet.toggle()
                    } label: {
                        Text("Dismiss")
                            .fontWeight(.bold)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.15, alignment: .center)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                    } .padding()
                    
                } else {
                    // Code for editing an idea
                    VStack {
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .foregroundColor(Color("\(currentIdea.color)"))
                                    .frame(width: 40, height: 40)
                                
                                Image(uiImage: UIImage(systemName: "\(currentIdea.icon)")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate) ?? UIImage(systemName: "questionmark.app")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))
                                    .resizable()
                                    .foregroundColor(.white)
                                    .scaledToFit()
                                    .padding(10)
                                    .cornerRadius(30)
                            } .frame(width: 45, height: 45, alignment: .center)
                            TextField("App Idea", text: $currentIdea.name)
                                .font(.system(size: 35, weight: .bold))
                                .font(.largeTitle)
                            Spacer()
                        } .padding(.top, 40)
                        .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .topLeading)
                        VStack {
                            if #available(iOS 15.0, *) {
                                Text("Date Created: \(currentIdea.date.formatted())")
                            } else {
                                // Fallback on earlier versions
                                Text("Date Created: \(formatter.string(from: currentIdea.date))")
                            }
                            if showNotes {
                                TextEditor(text: $currentIdea.notes)
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.3, alignment: .topLeading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(15)
                            }
                            
                            //Colors and Icon
                            HStack {
                                HStack {
                                    VStack {
                                        Button {
                                            currentIdea.color = "red2"
                                        } label: {
                                            Rectangle()
                                                .foregroundColor(Color("red2"))
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .cornerRadius(5)
                                        }
                                        Button {
                                            currentIdea.color = "orange2"
                                        } label: {
                                            Rectangle()
                                                .foregroundColor(Color("orange2"))
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .cornerRadius(5)
                                        }
                                        Button {
                                            currentIdea.color = "yellow2"
                                        } label: {
                                            Rectangle()
                                                .foregroundColor(Color("yellow2"))
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .cornerRadius(5)
                                        }
                                    }
                                
                                    VStack {
                                        Button {
                                            currentIdea.color = "pink2"
                                        } label: {
                                            Rectangle()
                                                .foregroundColor(Color("pink2"))
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .cornerRadius(5)
                                        }
                                        Button {
                                            currentIdea.color = "lightblue2"
                                        } label: {
                                            Rectangle()
                                                .foregroundColor(Color("lightblue2"))
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .cornerRadius(5)
                                        }
                                        Button {
                                            currentIdea.color = "blue2"
                                        } label: {
                                            Rectangle()
                                                .foregroundColor(Color("blue2"))
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .cornerRadius(5)
                                        }
                                    }
                                
                                    VStack {
                                        Button {
                                            currentIdea.color = "purple2"
                                        } label: {
                                            Rectangle()
                                                .foregroundColor(Color("purple2"))
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .cornerRadius(5)
                                        }
                                        Button {
                                            currentIdea.color = "darkblue2"
                                        } label: {
                                            Rectangle()
                                                .foregroundColor(Color("darkblue2"))
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .cornerRadius(5)
                                        }
                                        Button {
                                            currentIdea.color = "green2"
                                        } label: {
                                            Rectangle()
                                                .foregroundColor(Color("green2"))
                                                .frame(width: 35, height: 35, alignment: .center)
                                                .cornerRadius(5)
                                        }
                                    }
                            }
                                .padding()
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(15)
                                
                                VStack {
                                    HStack {
                                        Button {
                                            currentIdea.icon = "house.fill"
                                        } label: {
                                            Image(systemName: "house.fill")
                                                .resizable()
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .foregroundColor(.white)
                                                .padding(.trailing, 5)
                                        }
                                        Button {
                                            currentIdea.icon = "car"
                                        } label: {
                                            Image(systemName: "car")
                                                .resizable()
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .foregroundColor(.white)
                                                .padding(.leading, 5)
                                                .padding(.trailing, 5)
                                        }
                                        Button {
                                            currentIdea.icon = "highlighter"
                                        } label: {
                                            Image(systemName: "highlighter")
                                                .resizable()
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .foregroundColor(.white)
                                                .padding(.leading, 5)
                                        }
                                    }
                                    HStack {
                                        Button {
                                            currentIdea.icon = "note.text"
                                        } label: {
                                            Image(systemName: "note.text")
                                                .resizable()
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .foregroundColor(.white)
                                                .padding(.trailing, 5)
                                        }
                                        Button {
                                            currentIdea.icon = "book.fill"
                                        } label: {
                                            Image(systemName: "book.fill")
                                                .resizable()
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .foregroundColor(.white)
                                                .padding(.leading, 5)
                                                .padding(.trailing, 5)
                                        }
                                        Button {
                                            currentIdea.icon = "person.2.circle.fill"
                                        } label: {
                                            Image(systemName: "person.2.circle.fill")
                                                .resizable()
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .foregroundColor(.white)
                                                .padding(.leading, 5)
                                        }
                                    }
                                    HStack {
                                        Button {
                                            currentIdea.icon = "icloud.circle.fill"
                                        } label: {
                                            Image(systemName: "icloud.circle.fill")
                                                .resizable()
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .foregroundColor(.white)
                                                .padding(.trailing, 5)
                                        }
                                        Button {
                                            currentIdea.icon = "speaker.wave.2.circle.fill"
                                        } label: {
                                            Image(systemName: "speaker.wave.2.circle.fill")
                                                .resizable()
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .foregroundColor(.white)
                                                .padding(.leading, 5)
                                                .padding(.trailing, 5)
                                        }
                                        Button {
                                            currentIdea.icon = "desktopcomputer"
                                        } label: {
                                            Image(systemName: "desktopcomputer")
                                                .resizable()
                                                .frame(width: 25, height: 25, alignment: .center)
                                                .foregroundColor(.white)
                                                .padding(.leading, 5)
                                        }
                                    }
                                    
                                    HStack {
                                        TextField("Custom Symbol", text: $currentIdea.icon)
                                            .frame(width: 130)
                                            .multilineTextAlignment(.center)
                                            .autocapitalization(UITextAutocapitalizationType.none)
                                            .foregroundColor(.white)
                                    }
                                    
                                }
                                .padding()
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(15)
                            }
                            .padding()
                            //----
                            
                            Button {
                                showSheet.toggle()
                            } label: {
                                Text("Dismiss")
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.15, alignment: .center)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(15)
                            }

                        } .padding()
                    }
                    .padding()
                    .onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                            showNotes = true
                        })
                    })
                }
            }
            .padding(.leading)
            .padding(.trailing)
            .onAppear(perform: {
                newName = ""
                newNotes = ""
                newIcon = "house.fill"
                newColor = "red2"
            })
        })
    }
    
    private func deleteItem(at indexSet: IndexSet) {
            self.ideas.remove(atOffsets: indexSet)
            Idea.saveToFile(ideas)
        }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            //.preferredColorScheme(.dark)
    }
}
//
//struct Idea: Hashable {
//    var name: String
//    var notes: String
//    var date: Date
//    var color: Color
//    var icon: String
//}
