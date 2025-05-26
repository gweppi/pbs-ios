//
//  ContentView.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 25/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var vm = VM()
    @State private var athleteId: String = "5133523"
    
    @State private var data: Obj?
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
            Task { await fetch(id: newValue) }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            isSearching = false
        }
    }
}

#Preview {
    ContentView()
}
