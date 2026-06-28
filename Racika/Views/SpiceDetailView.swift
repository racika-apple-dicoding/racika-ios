import SwiftUI

struct SpiceDetailView: View {
    let result: SpiceDetectionResult
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedRegionalLanguage: String?
    @State private var showDeleteConfirm = false

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
                    headerSection
                    if !result.about.isEmpty {
                        aboutSection
                    }
                    if !result.storageMethod.isEmpty {
                        storageSection
                    }
                    if !result.regionalNames.isEmpty {
                        regionalNamesSection
                    }
                }
                .padding(.bottom, 120)
            }
            footerSection
        }
        .background(Color.rBg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(Color.rRed)
                }
            }
        }
        .confirmationDialog("Hapus riwayat scan ini?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Hapus", role: .destructive) {
                onDelete()
                dismiss()
            }
            Button("Batal", role: .cancel) {}
        }
        .onAppear { triggerAnimations() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(uiImage: result.capturedImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                .padding(.top, 24)

            VStack(spacing: 4) {
                Text(result.displayName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)

                if !result.latinName.isEmpty {
                    Text(result.latinName)
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.75))
                }
            }

            // Accuracy badge
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

            // Tanggal scan
            Text(formatDate(result.capturedDate))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 4)
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

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TENTANG")
                .font(.system(size: 12, weight: .bold))
                .tracking(2)
                .foregroundColor(Color.rText3)

            Text(result.about)
                .font(.system(size: 16))
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

    // MARK: - Storage

    private var storageSection: some View {
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
                    Image(systemName: result.storageIcon.isEmpty ? "box.square.fill" : result.storageIcon)
                        .font(.system(size: 20))
                        .foregroundColor(Color.rAmber)
                }
                Text(result.storageMethod)
                    .font(.system(size: 15))
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

    // MARK: - Regional Names

    private var regionalNamesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NAMA LAIN")
                .font(.system(size: 12, weight: .bold))
                .tracking(2)
                .foregroundColor(Color.rText3)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(result.regionalNames) { region in
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
                                selectedRegionalLanguage = selectedRegionalLanguage == region.language ? nil : region.language
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .opacity(showRegional ? 1 : 0)
    }

    // MARK: - Footer

    private var footerSection: some View {
        Button(role: .destructive, action: { showDeleteConfirm = true }) {
            HStack(spacing: 8) {
                Image(systemName: "trash.fill")
                Text("Hapus dari Riwayat")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(Color.rRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.rRedBg)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.rRed.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .background(
            Color.rBg
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
        )
    }

    // MARK: - Helpers

    private func triggerAnimations() {
        withAnimation(.easeOut(duration: 0.45).delay(0.1)) { showTitle = true }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) { showAccuracy = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.3)) { showAbout = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.4)) { showStorage = true }
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) { showRegional = true }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
}
