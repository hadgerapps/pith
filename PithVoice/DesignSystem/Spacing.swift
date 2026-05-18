import CoreGraphics

extension DS {
    /// 4-point spacing scale.
    ///
    /// Every spatial decision in the app (padding, gap, margin) must use a
    /// value from this enum. SwiftLint `no_raw_padding_outside_design_system`
    /// rule enforces this; `.padding(DS.Space.m)` is correct, `.padding(16)`
    /// is a lint error.
    enum Space {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    /// Corner radii. Use `DS.Radius.md` not `.cornerRadius(12)`.
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 32
        static let pill: CGFloat = 999
    }

    /// Hairline thickness. Always 1 logical point.
    enum Stroke {
        static let hairline: CGFloat = 1
    }
}
