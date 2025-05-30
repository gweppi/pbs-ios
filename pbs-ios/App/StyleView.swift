//
//  StyleView.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 30/05/2025.
//

import SwiftUI

struct StyleView: View {
    @Environment(ViewModel.self) var vm
    
    @State private var results: [PersonalBest]?
    @State private var error: Error?
    
    @State private var athleteId: String
    @State private var styleId: String
    @State private var course: String
    
    @State private var sortType: SortType = .time
    
    init(athleteId: String, styleId: String, course: String) {
        self.athleteId = athleteId
        self.styleId = styleId
        self.course = course
    }
    
    func fetch() async {
        do {
            results = try await vm.style(athleteId: self.athleteId, styleId: self.styleId, course: self.course)
        } catch {
            print(error)
            self.error = error
        }
    }
    
    enum SortType {
        case time, date
    }
    
    var body: some View {
        if let results, !results.isEmpty {
            List(results, id: \.self) { result in
                HStack {
                    VStack(alignment: .leading) {
                        Text(result.time)
                            .bold()
                        Text(result.city)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(result.date)
                }
            }
            .navigationTitle("\(results[0].event) (\(results[0].course))")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Picker("Select sorting option", selection: $sortType) {
                            Label("Tijd", systemImage: "timer")
                                .tag(SortType.time)
                            Label("Datum", systemImage: "calendar")
                                .tag(SortType.date)
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    
                }
                
            }
            .onChange(of: sortType) { _, newValue in
                switch newValue {
                case .time:
                    self.results?.sort { $0.time < $1.time }
                case .date:
                    self.results?.sort {
                        let date0 = try? Date(string: $0.date)
                        let date1 = try? Date(string: $1.date)
                        
                        if let date0, let date1 {
                            return date0 > date1
                        }
                        
                        return false
                    }
                    break
                @unknown default:
                    break
                }
            }
        } else {
            if let error {
                Text(error.localizedDescription)
            } else {
                ProgressView()
                    .task { await fetch() }
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

#Preview {
    NavigationStack {
        StyleView(athleteId: "5133523", styleId: "2", course: "25m")
            .navigationBarTitleDisplayMode(.inline)
    }
    .environment(ViewModel())
}
