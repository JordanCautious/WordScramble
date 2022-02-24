//
//  ContentView.swift
//  WordScramble
//
//  Created by Jordan Haynes on 2/17/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var selectionA = 2
    
    var body: some View {
        NavigationView {
            List {
                // Enter your word
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                // Correct words guessed
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack {
                            Spacer()
                            Text(word)
                                .padding(10)
                            Spacer()
                        }
                        .background(.green)
                        .clipShape(Capsule())
                        .font(.title2)
                        .foregroundColor(.white)
                    }
                }
                
                // Confidence Picker
                Section {
                    VStack {
                        Text("How confident are you?")
                            .foregroundColor(.teal)
                        Picker(selection: $selectionA, label: Text("Pick one:")) {
                            Image(systemName: "tortoise.fill").tag(1)
                            Image(systemName: "hare.fill").tag(2)
                            Image(systemName: "bolt.fill").tag(3)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                // Button to start a new game
                Section {
                    HStack {
                        Spacer()
                        Button(action: startGame) {
                            Label("Start a new game?", systemImage: "forward.fill")
                        }
                        .foregroundColor(.teal)
                        .font(.title2)
                        Spacer()
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // Returns errors if the word has already been used, not possible, or not valid
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You do know that you can't just make up words, right?")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    // Picks a random word from the list to start
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
        
        
    }
    
    // Logic needed to see if the word is original
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // Logic needed to see if the word is possible
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    // Logic needed to see if the word is real/valid
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    // Provides framework needed for word error
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
        ContentView()
            .preferredColorScheme(.light)
    }
}
