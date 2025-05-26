//
//  ContentView.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 25/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var vm = VM()
    @State private var athleteId: String = ""
    
    @State private var data: Obj?
    @State private var athletes: [Athlete]?
    @State private var error: Error?
    
    @State private var isSearching = false
    
    init() {
        UISearchBar.appearance().showsCancelButton = false
    }
    
    func fetch(id: String = "5133523") async {
//        Valid ids have a length of seven, this reduces the number of calls to the api
        if id.count < 7 { return }
        
        do {
            self.data = try await vm.fetch(id: id)
        } catch {
            print(error)
            self.error = error
        }
    }
    
    func search(value: String) async {
        do {
            self.athletes = try await vm.search(name: value)
        } catch {
            print(error)
            self.error = error
        }
    }
    
    var body: some View {
        NavigationView {
            if data != nil {
                List(data?.pbs ?? [], id: \.self) { pb in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(pb.event)
                            HStack {
                                Text(pb.time)
                                    .bold()
                                Text("|")
                                Text(pb.course)
                            }
                        }
                        
                        Spacer()
                        
                        Text(pb.date)
                    }
                }
                .navigationTitle("\(data?.info.lastName ?? ""), \(data?.info.firstName ?? "")")
                .onTapGesture { isSearching = false }
            } else {
                if let error {
                    if let pbError = error as? PBError {
                        Text(pbError.error)
                    } else {
                        Text(error.localizedDescription)
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .searchable(text: $athleteId, isPresented: $isSearching)
        .task {
            await fetch()
        }
        .onChange(of: athleteId) { _, newValue in
            if athleteId == "" { return }
            Task {
                if newValue.contains(/[0-9]/) { // if the string contains numbers, it is probably an ID
                    isSearching = false
                    await fetch(id: newValue)
                    athleteId = ""
                    athletes = nil
                } else {
                    await search(value: newValue)
                }
            }
        }
        .searchSuggestions {
            if let athletes {
                ForEach(athletes) { athlete in
                    Text(athlete.lastName + ", " + athlete.firstName)
                        .searchCompletion(athlete.id)
                }
            } else {
                Text("No search suggestions")
            }
        }
    }
}

#Preview {
    ContentView()
}
