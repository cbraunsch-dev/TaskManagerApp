// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Error {
    /// An error occurred
    internal static let generic = L10n.tr("Localizable", "error.generic")
    internal enum DataAccessor {
      /// Failed to access the local database
      internal static let failedToAccessDatabase = L10n.tr("Localizable", "error.dataAccessor.failedToAccessDatabase")
      /// The item you are trying to delete could not be found in the local database
      internal static let itemToDeleteNotFound = L10n.tr("Localizable", "error.dataAccessor.itemToDeleteNotFound")
      /// The device has run out of storage space
      internal static let outOfDiskSpace = L10n.tr("Localizable", "error.dataAccessor.outOfDiskSpace")
    }
    internal enum Generic {
      /// Error
      internal static let short = L10n.tr("Localizable", "error.generic.short")
    }
  }

  internal enum Table {
    internal enum Item {
      internal enum Placeholder {
        /// You have not added any tasks yet
        internal static let noTasksAvailable = L10n.tr("Localizable", "table.item.placeholder.noTasksAvailable")
      }
    }
  }

  internal enum Title {
    /// Edit Task
    internal static let editTask = L10n.tr("Localizable", "title.editTask")
    /// Your Tasks
    internal static let viewTasks = L10n.tr("Localizable", "title.viewTasks")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
