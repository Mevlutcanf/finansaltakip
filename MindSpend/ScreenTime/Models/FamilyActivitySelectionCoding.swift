import Foundation
import FamilyControls

/// `FamilyActivitySelection` doğrudan SwiftData'da tutulmaz (rehber madde 12).
/// Bu yardımcı, seçimi `ShieldRule.selectionData` alanında saklanabilecek
/// opak `Data`'ya çevirir. Token'ların ham değerleri kullanıcıya veya
/// export'a gösterilmez (rehber madde 34).
enum FamilyActivitySelectionCoding {
    static func encode(_ selection: FamilyActivitySelection) -> Data {
        (try? JSONEncoder().encode(selection)) ?? Data()
    }

    static func decode(_ data: Data) -> FamilyActivitySelection {
        (try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)) ?? FamilyActivitySelection()
    }
}
