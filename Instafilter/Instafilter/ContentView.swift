//
//  ContentView.swift
//  Instafilter
//
//  Created by Oluwapelumi Williams on 26/09/2023.
//


import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI


struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var showingFilterSheet = false
    
    @State private var processedImage: UIImage?
    
    let color1 = Color(red: 0.0312, green: 0.2969, blue: 0.3789)
    let color2 = Color(red: 0.8555, green: 0.3125, blue: 0.2891)
    let color3 = Color(red: 0.8867, green: 0.7070, blue: 0.0195)
    
    // titleColor is the same as color3
    let titleColor = UIColor(red: 0.8867, green: 0.7070, blue: 0.0195, alpha: 1)
    
    // this initializer is to be able to set the color of the navigationTitle
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
    }
    
    
    // body
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                        .opacity(0.7)
                    
                    VStack{
                        Text("Tap to select a picture")
                            .foregroundColor(color2)
                            .font(.headline)
                        Image(systemName: "photo")
                            .font(.system(size: 70.0))
                            .foregroundColor(.red)
                            .padding([.top], 2)
                    }
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    // select an image
                    showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                        .foregroundColor(color3)
                    Slider(value: $filterIntensity)
                        .accentColor(color2)
                        .onChange(of: filterIntensity) { _ in
                            applyProcessing()
                        }
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") {
                        // change the filter
                        showingFilterSheet = true
                    }
                    .foregroundColor(color3)
                    
                    Spacer()
                    
                    // save the picture
                    Button("Save", action: save)
                        .foregroundColor(color3)
                }
            }
            .padding([.horizontal, .bottom])
            
            // navigation title
            .navigationTitle(Text("Instafilter"))
            //.foregroundColor(color2)
            
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
                    .ignoresSafeArea()
            }
            .onChange(of: inputImage) { _ in loadImage() }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                // dialog goes here
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Cancel", role: .cancel) { }
            }
            .background(color1)
            
        } // closing brace of the NavigationView
    } // closing brace of the body
    
    // save function
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        // imageSaver.writeToPhotoAlbum(image: processedImage)
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops: \($0.localizedDescription)")
        }
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    // function to execute when the ImagePicker has been dismissed
    func loadImage() {
        guard let inputImage = inputImage else { return }
        // image = Image(uiImage: inputImage)
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    // function to apply some processing
    func applyProcessing() {
        // currentFilter.intensity = Float(filterIntensity)
        // currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    // function to set the filter
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    
} // closing brace of the ContentView

#Preview {
    ContentView()
}
