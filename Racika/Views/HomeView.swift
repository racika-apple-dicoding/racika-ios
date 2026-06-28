//
//  HomeView.swift
//  Racika
//
//  Created by Daffa Putera Kouseina on 28/06/26.
//

import SwiftUI

struct HomeView: View {
    private var historyStore = HistoryStore.shared
    @State private var selectedResult: SpiceDetectionResult?
    @State private var showAskWifeAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Scan Card
                    NavigationLink(value: "camera") {
                        VStack {
                            thumbnailCard
                            heroCard
                        }
                    }
                    .buttonStyle(.plain)

                    // MARK: - Tanya ke Istri Button
                    askWifeButton

                    // MARK: - Riwayat
                    Text("Riwayat scan")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.rText2)
                        .padding(.top, 4)

                    historyList
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color.rBg.ignoresSafeArea())
            .navigationDestination(for: String.self) { value in
                if value == "camera" {
                    CameraView()
                }
            }
            .navigationDestination(for: SpiceDetectionResult.self) { result in
                SpiceDetailView(result: result) {
                    historyStore.delete(result)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Racika")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.rText1)
                }
            }
            .toolbarBackground(Color.rBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Tanya ke Istri 👩‍🍳", isPresented: $showAskWifeAlert) {
                Button("Oke, siap!", role: .cancel) {}
            } message: {
                Text("Fitur ini sedang dalam pengembangan. Segera hadir!")
            }
        }
    }

    // MARK: - Thumbnail Card

    private var thumbnailCard: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0))
                    .frame(width: 200, height: 200)
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 200))
                    .foregroundStyle(Color.rBrown)
            }
            Text("Deteksi Rempah - Rempah")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)

            Text(
                "Foto atau pindai bahan makanan\nuntuk mendapatkan bahan"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 44, height: 44)
                Image(systemName: "camera.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Scan rempah")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Text("Foto untuk identifikasi")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.72))
            }
            Spacer()
        }
        .padding(16)
        .background(Color.rBrown)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Ask Wife Button

    private var askWifeButton: some View {
        Button(action: { showAskWifeAlert = true }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.rGreenBg)
                        .frame(width: 44, height: 44)
                    Text("👩‍🍳")
                        .font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Tanya ke Istri")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.rText1)
                        Text("SEGERA")
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(1)
                            .foregroundStyle(Color.rGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.rGreenBg)
                            .clipShape(Capsule())
                    }
                    Text("Tanya resep atau tips memasak")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.rText3)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.rText3.opacity(0.5))
            }
            .padding(14)
            .background(Color.rCream)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.rBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - History List

    private var historyList: some View {
        VStack(spacing: 0) {
            if historyStore.items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock.badge.xmark")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.rText3.opacity(0.5))
                        .padding(.top, 16)
                    Text("Belum ada riwayat scan.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.rText3)
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 0) {
                    ForEach(historyStore.items) { item in
                        NavigationLink(value: item) {
                            HistoryRow(item: item)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation { historyStore.delete(item) }
                            } label: {
                                Label("Hapus", systemImage: "trash.fill")
                            }
                        }

                        if item.id != historyStore.items.last?.id {
                            Divider()
                                .background(Color.rBorder)
                        }
                    }
                }
                .background(Color.rCream)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.rBorder, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - History Row

private struct HistoryRow: View {
    let item: SpiceDetectionResult

    var body: some View {
        HStack(spacing: 12) {
            Image(uiImage: item.capturedImage)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.rText1)
                HStack(spacing: 4) {
                    Text("\(Int(item.accuracy * 100))% akurat")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(item.accuracy > 0.5 ? Color.rGreen : Color.rAmber)
                    Text("·")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.rText3)
                    Text(formatDate(item.capturedDate))
                        .font(.system(size: 11))
                        .foregroundStyle(Color.rText3)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.rText3.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - FeatureCard (unused, reserved)

private struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.rBrownLight)
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.rBrownDark)
            }
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.rText1)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(Color.rText3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.rCream)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.rBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    HomeView()
}
