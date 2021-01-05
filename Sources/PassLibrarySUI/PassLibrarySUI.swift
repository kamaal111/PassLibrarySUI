//
//  PassLibrarySUI.swift
//  
//
//  Created by Kamaal M Farah on 05/01/2021.
//

import SwiftUI
import PassLibrary
import Combine
import PassKit

public final class AddPKPassHandler: ObservableObject {
    @Published public var showAddPassView = false
    @Published public var pass: PKPass? {
        didSet {
            guard pass != nil else { return }
            showAddPassView = true
        }
    }

    private var lastFailures: Error? {
        didSet {
            #if DEBUG
            if let lastFailures = self.lastFailures {
                print("AddPKPassHandler ERROR:", lastFailures.localizedDescription)
            }
            #endif
        }
    }

    public init() { }

    public func openPKPass(from url: URL) {
        let passLibrary = PassLibrary()
        passLibrary.getRemotePKPass(from: url) { [weak self] (result: Result<Data, Error>) in
            let pkPassData: Data
            switch result {
            case .failure(let failure):
                self?.lastFailures = failure
                return
            case .success(let data):
                pkPassData = data
            }
            do {
                self?.pass = try PKPass(data: pkPassData)
            } catch {
                self?.lastFailures = error
            }
        }
    }
}

internal struct AddPKPassViewContent: UIViewControllerRepresentable {
    internal let passes: [PKPass]

    internal init(passes: [PKPass]?) {
        self.passes = passes ?? []
    }

    internal init(pass: PKPass?) {
        if let pass = pass {
            self.passes = [pass]
        } else {
            self.passes = []
        }
    }

    func makeUIViewController(context: Context) -> UIViewControllerType {
        let pkAddPassViewController: PKAddPassesViewController?
        if passes.count == 1 {
            pkAddPassViewController = PKAddPassesViewController(pass: self.passes.first!)
        } else {
            pkAddPassViewController = PKAddPassesViewController(passes: self.passes)
        }
        return pkAddPassViewController ?? PKAddPassesViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

    typealias UIViewControllerType = PKAddPassesViewController
}

public struct AddPKPassView<Presenting>: View where Presenting: View {
    @Binding public var isShowing: Bool

    public var presenting: () -> Presenting
    public var passes: [PKPass]?

    public init(isShowing: Binding<Bool>, presenting: @escaping () -> Presenting, passes: [PKPass]?) {
        self._isShowing = isShowing
        self.presenting = presenting
        self.passes = passes
    }

    public init(isShowing: Binding<Bool>, presenting: @escaping () -> Presenting, pass: PKPass?) {
        self._isShowing = isShowing
        self.presenting = presenting
        if let pass = pass {
            self.passes = [pass]
        } else {
            self.passes = []
        }
    }

    public var body: some View {
        self.presenting()
            .sheet(isPresented: self.$isShowing) {
                AddPKPassViewContent(passes: self.passes)
        }
    }
}

public extension View {
    func addPKPassSheet(isShowing: Binding<Bool>, pass: PKPass?) -> some View {
        return AddPKPassView(isShowing: isShowing, presenting: { self }, pass: pass)
    }

    func addPKPassSheet(isShowing: Binding<Bool>, passess: [PKPass]?) -> some View {
        return AddPKPassView(isShowing: isShowing, presenting: { self }, passes: passess)
    }
}
