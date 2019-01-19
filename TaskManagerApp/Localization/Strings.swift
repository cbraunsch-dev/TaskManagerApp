// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Action {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "action.cancel")
    /// OK
    internal static let ok = L10n.tr("Localizable", "action.ok")
    internal enum Task {
      /// Edit name
      internal static let editName = L10n.tr("Localizable", "action.task.editName")
      /// Edit notes
      internal static let editNotes = L10n.tr("Localizable", "action.task.editNotes")
      internal enum EditName {
        /// E.g. Buy food
        internal static let hint = L10n.tr("Localizable", "action.task.editName.hint")
        /// Enter a name for your task
        internal static let info = L10n.tr("Localizable", "action.task.editName.info")
        /// Name
        internal static let title = L10n.tr("Localizable", "action.task.editName.title")
      }
      internal enum EditNotes {
        /// Additional notes...
        internal static let hint = L10n.tr("Localizable", "action.task.editNotes.hint")
        /// Enter some notes for your task
        internal static let info = L10n.tr("Localizable", "action.task.editNotes.info")
        /// Notes
        internal static let title = L10n.tr("Localizable", "action.task.editNotes.title")
      }
    }
  }

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
