import SwiftUI

struct RecipeResultsView: View {
    let extractedSpices: [String]
    
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Berikut adalah bahan-bahan yang berhasil diekstrak dari gambar resep Anda:")
                        .font(.system(size: 15))
                        .foregroundColor(Color.rText2)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    if extractedSpices.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "text.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(Color.rText3)
                            Text("Tidak ada teks yang terdeteksi.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.rText3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(extractedSpices.enumerated()), id: \.offset) { index, spice in
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.rBrown.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "text.quote")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color.rBrown)
                                    }
                                    
                                    Text(spice)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color.rText1)
                                        .lineLimit(2)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.rGreen)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                
                                if index < extractedSpices.count - 1 {
                                    Divider()
                                        .background(Color.rBorder)
                                        .padding(.leading, 72)
                                }
                            }
                        }
                        .background(Color.rCream)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rBorder, lineWidth: 1))
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 120)
            }
            
            // Footer Action
            if !extractedSpices.isEmpty {
                VStack {
                    Button(action: {
                        ShoppingListStore.shared.save(ingredients: extractedSpices)
                        showSuccessAlert = true
                    }) {
                        Text("Simpan ke Daftar Belanja")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.rGreen)
                            .clipShape(Capsule())
                            .shadow(color: Color.rGreen.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .background(
                    Color.rBg
                        .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
                )
            }
        }
        .background(Color.rBg.ignoresSafeArea())
        .navigationTitle("Bumbu Ditemukan")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Berhasil!", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Daftar bahan telah disimpan ke Daftar Belanja Anda.")
        }
    }
}
