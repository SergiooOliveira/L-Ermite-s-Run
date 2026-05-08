//
//  MainLayoutView.swift
//  L'HermitsRun
//
//  Created by Aluno Tmp on 08/05/2026.
//

import SwiftUI

struct MainLayoutView: View {
    var body: some View {
        VStack(spacing: 4) {
            // 1. TOP SECTION
            TopHeaderView()
                .frame(height: 120) // Adjust height as needed
            
            // 2. MIDDLE SECTION (4 Columns)
            FourColumnGridRow()
                .frame(maxHeight: .infinity) // Fills available space
            
            // 3. BOTTOM SECTION (4 Columns)
            FourColumnGridRow()
                .frame(height: 150)
        }
        .padding()
    }
}

// MARK: - Modular Components

struct TopHeaderView: View {
    var body: some View {
        Rectangle()
            .stroke(Color.black, lineWidth: 4)
            .overlay(Text("Top Component").foregroundColor(.gray))
    }
}

struct FourColumnGridRow: View {
    var body: some View {
        HStack(spacing: 0) {
            // Column 1
            GridCell(title: "Col 1")
            Divider().background(Color.red).frame(width: 2)
            
            // Column 2
            GridCell(title: "Col 2")
            Divider().background(Color.red).frame(width: 2)
            
            // Column 3
            GridCell(title: "Col 3")
            Divider().background(Color.red).frame(width: 2)
            
            // Column 4
            GridCell(title: "Col 4")
        }
        .border(Color.black, width: 4)
    }
}

struct GridCell: View {
    var title: String
    
    var body: some View {
        // You can replace this entirely with whatever content you want later
        Rectangle()
            .fill(Color.clear)
            .frame(maxWidth: .infinity) // Ensures all columns stay equal width
            .overlay(Text(title).foregroundColor(.gray))
    }
}
