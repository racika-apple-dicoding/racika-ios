import SwiftUI

struct ShoppingListView: View {
    let store = ShoppingListStore.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if store.items.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(store.items) { item in
                        ShoppingListRow(item: item) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                store.toggle(item: item)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            for index in indexSet {
                                let item = store.items[index]
                                store.delete(item: item)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.top, 16)
            }
        }
        .background(Color.rBg.ignoresSafeArea())
        .navigationTitle("Daftar Belanja")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart.badge.minus")
                .font(.system(size: 48))
                .foregroundColor(Color.rText3.opacity(0.5))
            Text("Daftar belanja kosong.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.rText3)
            Text("Mulai scan resep untuk menambahkan daftar bahan otomatis ke sini.")
                .font(.system(size: 14))
                .foregroundColor(Color.rText3.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }
}

private struct ShoppingListRow: View {
    let item: ShoppingListItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Checkbox
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(item.isChecked ? Color.rGreen : Color.rText3.opacity(0.5))
                
                // Text
                Text(item.name)
                    .font(.system(size: 16, weight: item.isChecked ? .regular : .semibold))
                    .foregroundColor(item.isChecked ? Color.rText3 : Color.rText1)
                    .strikethrough(item.isChecked, color: Color.rText3)
                
                Spacer()
            }
            .padding(16)
            .background(Color.rCream)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rBorder, lineWidth: 1))
            .opacity(item.isChecked ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
