//
//  ImageCropperView.swift
//  Makuli
//
//  Created by Ian on 2025-07-22.
//

import SwiftUI

struct ImageCropperView: View {
    let image: UIImage
    var onCrop: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                ZStack {
                    Color.black.opacity(0.8)
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = value
                                }
                                .simultaneously(with:
                                    DragGesture()
                                        .onChanged { value in
                                            offset = value.translation
                                        }
                                )
                        )
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .overlay(
                            Rectangle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .frame(width: geometry.size.width, height: geometry.size.width)
            }
            .frame(height: 350)
            Spacer()
            Button("Crop & Use Photo") {
                let cropped = cropImage()
                onCrop(cropped)
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 8)
        }
        .padding()
    }

    private func cropImage() -> UIImage {
        let originalSize = image.size
        let side = min(originalSize.width, originalSize.height)
        let cropRect = CGRect(
            x: (originalSize.width - side) / 2,
            y: (originalSize.height - side) / 2,
            width: side,
            height: side
        )
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }
        return image
    }
} 