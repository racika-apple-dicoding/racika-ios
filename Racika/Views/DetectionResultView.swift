import SwiftUI

struct DetectionResultView: View {
    let result: SpiceDetectionResult
    let onSave: (SpiceDetectionResult) -> Void
    let onRetake: () -> Void
    
    @State private var isLoading = true
    @State private var spiceInfo: SpiceAIInfo?
    @State private var fetchError: String?
    @State private var selectedRegionalLanguage: String?
    
    // Animation states
    @State private var showTitle = false
    @State private var showAccuracy = false
    @State private var showAbout = false
    @State private var showStorage = false
    @State private var showRegional = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - AI Content
                    if isLoading {
                        loadingView
                    } else if let error = fetchError {
                        errorView(message: error)
                    } else if let info = spiceInfo {
                        aboutSection(info: info)
                        storageSection(info: info)
                        if !info.regionalNames.isEmpty {
                            regionalNamesSection(info: info)
                        }
                    }
                }
                .padding(.bottom, 100) // Padding for sticky footer
            }
            
            // MARK: - Footer Actions
            footerSection
        }
        .background(Color.rBg.ignoresSafeArea())
        .onAppear {
            triggerAnimations()
            fetchData()
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(uiImage: result.capturedImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .padding(.top, 24)
            
            VStack(spacing: 4) {
                Text(result.displayName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)
                
                if let info = spiceInfo, !info.latinName.isEmpty {
                    Text(info.latinName)
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.75))
                }
            }
            
            // Accuracy Badge
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(result.accuracy > 0.5 ? Color.rGreen : Color.rAmber)
                Text("\(Int(result.accuracy * 100))% Akurat")
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.rCream)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.rBorder, lineWidth: 1))
            .foregroundColor(Color.rText2)
            .scaleEffect(showAccuracy ? 1 : 0.8)
            .opacity(showAccuracy ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
        .background(
            Color.rBrown
                .ignoresSafeArea()
                .cornerRadius(32, corners: [.bottomLeft, .bottomRight])
                .shadow(color: Color.rBrown.opacity(0.2), radius: 15, y: 5)
        )
    }
    
    private func aboutSection(info: SpiceAIInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TENTANG")
                .font(.system(size: 12, weight: .bold))
                .tracking(2)
                .foregroundColor(Color.rText3)
            
            Text(info.about)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.rText1)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.rCream)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.rBorder, lineWidth: 1))
        .padding(.horizontal, 20)
        .opacity(showAbout ? 1 : 0)
        .offset(y: showAbout ? 0 : 20)
    }
    
    private func storageSection(info: SpiceAIInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CARA MENYIMPAN")
                .font(.system(size: 12, weight: .bold))
                .tracking(2)
                .foregroundColor(Color.rText3)
            
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.rAmber.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: info.storageIcon.isEmpty ? "box.square.fill" : info.storageIcon)
                        .font(.system(size: 20))
                        .foregroundColor(Color.rAmber)
                }
                
                Text(info.storageMethod)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.rText1)
                    .lineSpacing(4)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.rAmberBg)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.rAmber.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 20)
        .opacity(showStorage ? 1 : 0)
        .offset(y: showStorage ? 0 : 20)
    }
    
    private func regionalNamesSection(info: SpiceAIInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NAMA LAIN")
                .font(.system(size: 12, weight: .bold))
                .tracking(2)
                .foregroundColor(Color.rText3)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(info.regionalNames) { region in
                        let isSelected = selectedRegionalLanguage == region.language
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(region.language)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(isSelected ? .white.opacity(0.8) : Color.rText3)
                            Text(region.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(isSelected ? .white : Color.rText1)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(isSelected ? Color.rBrown : Color.rCream)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.clear : Color.rBorder, lineWidth: 1)
                        )
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                if selectedRegionalLanguage == region.language {
                                    selectedRegionalLanguage = nil
                                } else {
                                    selectedRegionalLanguage = region.language
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .opacity(showRegional ? 1 : 0)
    }
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                let finalResult = SpiceDetectionResult(
                    classLabel: result.classLabel,
                    displayName: result.displayName,
                    accuracy: result.accuracy,
                    capturedImage: result.capturedImage,
                    capturedDate: result.capturedDate,
                    latinName: spiceInfo?.latinName ?? "",
                    about: spiceInfo?.about ?? "",
                    storageMethod: spiceInfo?.storageMethod ?? "",
                    storageIcon: spiceInfo?.storageIcon ?? "",
                    regionalNames: spiceInfo?.regionalNames ?? []
                )
                onSave(finalResult)
            }) {
                Text("Simpan Hasil")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.rGreen)
                    .clipShape(Capsule())
                    .shadow(color: Color.rGreen.opacity(0.3), radius: 8, y: 4)
            }
            
            Button(action: onRetake) {
                Text("Scan Ulang")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.rText2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.clear)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .background(
            Color.rBg
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
        )
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.rBrown)
                .scaleEffect(1.5)
            Text("Memuat informasi dari AI...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.rText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.rRed)
            Text("Gagal memuat informasi")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.rText1)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color.rText3)
                .multilineTextAlignment(.center)
            Button("Coba Lagi") {
                fetchData()
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(Color.rBrown)
            .padding(.top, 8)
        }
        .padding(32)
        .background(Color.rRedBg)
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Logic
    
    private func triggerAnimations() {
        withAnimation(.easeOut(duration: 0.5).delay(0.15)) { showTitle = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.25)) { showAccuracy = true }
    }
    
    private func fetchData() {
        // Skip AI fetch for "bukan_rempah"
        if result.classLabel.lowercased() == "bukan_rempah" {
            isLoading = false
            fetchError = "Objek tidak dikenali sebagai rempah."
            return
        }
        
        isLoading = true
        fetchError = nil
        
        Task {
            do {
                let info = try await AIService.shared.fetchSpiceInfo(for: result.displayName)
                await MainActor.run {
                    self.spiceInfo = info
                    self.isLoading = false
                    
                    // Trigger stagger animations for AI content
                    withAnimation(.easeOut(duration: 0.5).delay(0.1)) { self.showAbout = true }
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) { self.showStorage = true }
                    withAnimation(.easeOut(duration: 0.5).delay(0.3)) { self.showRegional = true }
                }
            } catch {
                await MainActor.run {
                    self.fetchError = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// Extension to round specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
