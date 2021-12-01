public struct Person: Equatable {
    public var firstName: String
    public var lastName: String

    public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
