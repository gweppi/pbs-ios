//
//  ContentView.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 25/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var vm = ViewModel()
    @State private var athleteId: String
    @State private var searchText: String = ""
    
    @State private var pbs: PBS?
    @State private var athletes: [Athlete]?
    @State private var error: Error?
    
    @State private var isSearching = false
    
    let debouncer = Debouncer(delay: 0.3)
    
    init(athleteId: String = "5133523") {
        self.athleteId = athleteId
    }
    
    func fetch() async {
        do {
            self.pbs = try await vm.fetch(id: athleteId)
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
        NavigationStack {
            if let pbs = pbs, !pbs.pbs.isEmpty {
                List(pbs.pbs, id: \.self) { pb in
                    NavigationLink(destination: StyleView(athleteId: athleteId, styleId: pb.styleId, course: pb.course)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(pb.event)
                                HStack {
                                    Text(pb.time)
                                        .bold()
                                    Text("|")
                                    Text(pb.course)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Text(pb.date)
                        }
                    }
                    
                }
                .navigationTitle("\(pbs.info.lastName), \(pbs.info.firstName)")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                if let error {
                    if let pbError = error as? FetchError {
                        Text(pbError.error)
                    } else {
                        Text(error.localizedDescription)
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .searchable(text: $searchText, isPresented: $isSearching)
        .onChange(of: searchText) { _, newValue in
            if searchText == "" { return }
            debouncer.run {
                Task {
                    await search(value: newValue)
                }
            }
        }
        .task {
            await fetch()
        }
        .searchSuggestions {
            if let athletes, !athletes.isEmpty {
                ForEach(athletes) { athlete in
                    Button {
                        Task {
                            self.pbs = nil
                            self.athleteId = athlete.id
                            self.isSearching = false
                            await fetch()
                            self.searchText = ""
                            self.athletes = nil
                        }
                    } label : {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(athlete.lastName + ", " + athlete.firstName)
                                    .bold()
                                
                                Text("\(athlete.country ?? "") - \(athlete.club ?? "")")
                            }
                            
                            Spacer()
                            
                            Text(athlete.dobYear)
                        }
                    }
                    .foregroundStyle(.primary)
                }
            } else {
                Text("No search suggestions")
                    .foregroundStyle(.secondary)
            }
        }
        .environment(vm)
    }
}

#Preview {
    ContentView()
}
