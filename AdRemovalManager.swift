import StoreKit
import SwiftUI

@MainActor
final class AdRemovalManager: ObservableObject {
    static let shared = AdRemovalManager()
    static let productId = "com.tokyonasu.jikenflash.removeads"
    static let trainProductId = "com.tokyonasu.jikenflash.train"
    static let earthquakeProductId = "com.tokyonasu.jikenflash.earthquake"

    @Published var isAdFree = false
    @Published var product: Product?
    @Published var isPurchasing = false
    @Published var isTrainUnlocked = false
    @Published var isEarthquakeUnlocked = false
    @Published var trainProduct: Product?
    @Published var earthquakeProduct: Product?

    private init() {
        isAdFree = UserDefaults.standard.bool(forKey: "adFree")
        isTrainUnlocked = UserDefaults.standard.bool(forKey: "trainUnlocked")
        isEarthquakeUnlocked = UserDefaults.standard.bool(forKey: "earthquakeUnlocked")
        Task { await loadProduct() }
        Task { await listenForTransactions() }
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productId, Self.trainProductId, Self.earthquakeProductId])
            for product in products {
                switch product.id {
                case Self.productId: self.product = product
                case Self.trainProductId: trainProduct = product
                case Self.earthquakeProductId: earthquakeProduct = product
                default: break
                }
            }
        } catch {
            print("Product load error: \(error.localizedDescription)")
        }
    }

    func purchase() async {
        guard let product else { return }
        await purchase(product, unlock: { self.isAdFree = true; UserDefaults.standard.set(true, forKey: "adFree") })
    }

    func purchaseTrain() async {
        guard let trainProduct else { return }
        await purchase(trainProduct, unlock: { self.isTrainUnlocked = true; UserDefaults.standard.set(true, forKey: "trainUnlocked") })
    }

    func purchaseEarthquake() async {
        guard let earthquakeProduct else { return }
        await purchase(earthquakeProduct, unlock: { self.isEarthquakeUnlocked = true; UserDefaults.standard.set(true, forKey: "earthquakeUnlocked") })
    }

    private func purchase(_ product: Product, unlock: () -> Void) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result, case .verified(_) = verification {
                unlock()
            }
        } catch {
            print("Purchase error: \(error.localizedDescription)")
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    apply(transaction.productID)
                }
            }
        } catch {
            print("Restore error: \(error.localizedDescription)")
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                apply(transaction.productID)
                await transaction.finish()
            }
        }
    }

    private func apply(_ productID: String) {
        switch productID {
        case Self.productId:
            isAdFree = true
            UserDefaults.standard.set(true, forKey: "adFree")
        case Self.trainProductId:
            isTrainUnlocked = true
            UserDefaults.standard.set(true, forKey: "trainUnlocked")
        case Self.earthquakeProductId:
            isEarthquakeUnlocked = true
            UserDefaults.standard.set(true, forKey: "earthquakeUnlocked")
        default:
            break
        }
    }

    func isPremiumCategory(_ category: NewsCategory) -> Bool {
        category == .train || category == .earthquake
    }

    func isCategoryUnlocked(_ category: NewsCategory) -> Bool {
        switch category {
        case .train: return isTrainUnlocked
        case .earthquake: return isEarthquakeUnlocked
        default: return true
        }
    }
}
