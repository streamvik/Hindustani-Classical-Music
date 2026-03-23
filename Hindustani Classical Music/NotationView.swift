import SwiftUI

struct NotationView: View {
    @State private var title: String = ""
    @State private var notation: String = ""
    
    // Toggle States
    @State private var octave: Int = 1
    @State private var pitch: Int = 0
    
    // This holds the file location once the PDF is created
    @State private var pdfURL: URL?
    
    let swaras = ["S", "R", "G", "M", "P", "D", "N", "-"]
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 15) {
            
            // 1. THE TITLE FIELD
            TextField("Enter Bandish Title...", text: $title)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                // If they change the title, we hide the old PDF to avoid sharing outdated versions
                .onChange(of: title) { _ in pdfURL = nil }
            
            // 2. THE DISPLAY SCREEN
            ScrollView {
                Text(notation.isEmpty ? "Tap a Swara to start..." : notation)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding()
            }
            .frame(height: 180)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)
            .onChange(of: notation) { _ in pdfURL = nil } // Hide old PDF if notes change
            
            // 3. THE MODIFIER TOGGLES
            VStack(spacing: 10) {
                Picker("Octave", selection: $octave) {
                    Text("Lower").tag(0)
                    Text("Middle").tag(1)
                    Text("Upper").tag(2)
                }
                .pickerStyle(.segmented)
                
                Picker("Pitch", selection: $pitch) {
                    Text("Shuddha").tag(0)
                    Text("Komal").tag(1)
                    Text("Tivra").tag(2)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            // 4. THE SWARA KEYBOARD
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(swaras, id: \.self) { swara in
                    Button(action: {
                        addSwara(baseNote: swara)
                    }) {
                        Text(swara)
                            .font(.title2)
                            .bold()
                            .frame(width: 65, height: 65)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)
            
            // 5. THE STRUCTURE & TAAL BUTTONS
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StructureButton(title: "|", action: { notation += "| " })
                    StructureButton(title: "x", action: { notation += "x " })
                    StructureButton(title: "2", action: { notation += "2 " })
                    StructureButton(title: "0", action: { notation += "0 " })
                    StructureButton(title: "3", action: { notation += "3 " })
                    StructureButton(title: "4", action: { notation += "4 " })
                    
                    Button(action: { notation += "\n" }) {
                        Image(systemName: "return")
                            .font(.headline)
                            .frame(width: 50, height: 40)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            
            // 6. ACTION CONTROLS (Delete & Clear)
            HStack(spacing: 40) {
                Button(action: {
                    notation = ""
                    title = ""
                }) {
                    Text("Clear All")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    deleteLast()
                }) {
                    HStack {
                        Image(systemName: "delete.backward.fill")
                        Text("Delete")
                    }
                    .font(.headline)
                    .foregroundColor(.orange)
                }
            }
            .padding(.bottom, 5)
            
            Divider()
            
            // 7. SHARE & EXPORT ROW
            HStack(spacing: 30) {
                Button(action: {
                    pdfURL = renderPDF()
                }) {
                    HStack {
                        Image(systemName: "doc.viewfinder")
                        Text("Generate Document")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // This magically appears only when the PDF is ready
                if let url = pdfURL {
                    ShareLink(item: url) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share PDF")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.bottom, 10)
        }
    }
    
    // MARK: - PDF Generation Logic
    
    // This is the "Hidden Canvas" - A clean view just for the PDF
    var pdfLayout: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title.isEmpty ? "Untitled Bandish" : title)
                .font(.largeTitle)
                .bold()
            
            Text(notation)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .lineSpacing(10)
            
            Spacer()
        }
        .padding(40)
        .frame(width: 612, height: 792) // Standard 8.5 x 11 inch paper size
        .background(Color.white)
        .foregroundColor(.black)
    }
    
    @MainActor
    func renderPDF() -> URL? {
        let renderer = ImageRenderer(content: pdfLayout)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(title.isEmpty ? "Bandish" : title).pdf")
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        return url
    }
    
    // MARK: - App Functions
    
    func addSwara(baseNote: String) {
        if baseNote == "-" { notation += "- "; return }
        var formattedNote = baseNote
        if pitch == 1 { formattedNote += "\u{0331}" }
        else if pitch == 2 { formattedNote += "'" }
        if octave == 0 { formattedNote += "\u{0323}" }
        else if octave == 2 { formattedNote += "\u{0307}" }
        notation += formattedNote + " "
        pitch = 0
        octave = 1
    }
    
    func deleteLast() {
        if notation.hasSuffix(" ") { notation.removeLast() }
        if !notation.isEmpty { notation.removeLast() }
    }
}

struct StructureButton: View {
    var title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(width: 45, height: 40)
                .background(Color.gray.opacity(0.3))
                .foregroundColor(.black)
                .cornerRadius(8)
        }
    }
}

#Preview {
    NotationView()
}
