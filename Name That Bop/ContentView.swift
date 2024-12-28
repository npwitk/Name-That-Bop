//
//  ContentView.swift
//  Name That Bop
//
//  Created by Nonprawich I. on 26/12/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(colorScheme == .dark ? .black : .white),
                        Color.purple.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    AsyncImage(url: viewModel.shazamMedia.albumArtURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: min(geometry.size.width * 0.7, 300))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 10)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: min(geometry.size.width * 0.7, 300), height: min(geometry.size.width * 0.7, 300))
                    }
                    
                    VStack(spacing: 8) {
                        Text(viewModel.shazamMedia.title ?? "Title")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.shazamMedia.artistName ?? "Artist Name")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if let firstGenre = viewModel.shazamMedia.genres.first {
                                                    Text(firstGenre)
                                                        .font(.footnote)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(Color.purple.opacity(0.2))
                                                        .clipShape(Capsule())
                                                        .padding(.top, 8)
                                                }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background(colorScheme == .dark ? .ultraThinMaterial : .ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Spacer()
                    
                    Button(action: { viewModel.startOrEndListening() }) {
                        Circle()
                            .fill(viewModel.isRecording ? Color.purple.opacity(0.3) : Color.purple)
                            .frame(width: 80, height: 80)
                            .overlay {
                                if viewModel.isRecording {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.purple)
                                        .scaleEffect(1.5)
                                } else {
                                    Image(systemName: "waveform")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                            }
                    }
                    .padding(.bottom, 50)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
