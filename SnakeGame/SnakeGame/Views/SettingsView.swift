import SwiftUI

struct SettingsView: View {
    @ObservedObject var folderManager: FolderAccessManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Constants.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Text("AJUSTES")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(.green)
                    .shadow(color: .green.opacity(0.4), radius: 6)

                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 44))
                            .foregroundColor(.green)

                        Text("Acceso a Carpeta")
                            .font(.system(.title3, design: .monospaced).bold())
                            .foregroundColor(.white)

                        Text("Permite guardar tus puntuaciones en una carpeta de tu dispositivo")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    if folderManager.hasAccess, let name = folderManager.folderName {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(name)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(10)

                        Button(action: { folderManager.requestAccess() }) {
                            Text("CAMBIAR CARPETA")
                                .font(.system(.subheadline, design: .monospaced).bold())
                                .foregroundColor(.green)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                        }

                        Button(action: { folderManager.revokeAccess() }) {
                            Text("REVOCAR ACCESO")
                                .font(.system(.subheadline, design: .monospaced).bold())
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red, lineWidth: 2)
                                )
                        }
                    } else {
                        Button(action: { folderManager.requestAccess() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "folder.badge.plus")
                                Text("SOLICITAR ACCESO")
                            }
                            .font(.system(.title3, design: .monospaced).bold())
                            .foregroundColor(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .sheet(isPresented: $folderManager.showPicker) {
            FolderPickerView { url in
                folderManager.grantAccess(to: url)
            }
        }
    }
}
