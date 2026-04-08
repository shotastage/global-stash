import ArgumentParser

struct GStashCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "gstash",
        abstract: "gstash - Global Stash Tool",
        discussion: """
        Examples:
          gstash save myfile.txt
          gstash myfile.txt
          gstash list
          gstash apply 1
        """,
        subcommands: [
            Save.self,
            List.self,
            Apply.self,
            Drop.self,
            Clear.self,
        ],
        helpNames: [.long, .short]
    )

    static let commandNames: Set<String> = [
        "save",
        "s",
        "list",
        "ls",
        "l",
        "apply",
        "a",
        "drop",
        "d",
        "clear",
        "help",
    ]

    mutating func run() async throws {
        throw CleanExit.helpRequest(self)
    }
}

struct Save: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "save",
        abstract: "Save a file to stash.",
        aliases: ["s"]
    )

    @Argument(help: "Path to the file to stash.")
    var filePath: String

    mutating func run() async throws {
        await CLIRunner.handleSave(filePath: filePath)
    }
}

struct List: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all stashed files.",
        aliases: ["ls", "l"]
    )

    mutating func run() async throws {
        await CLIRunner.handleList()
    }
}

struct Apply: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "apply",
        abstract: "Apply a stash.",
        aliases: ["a"]
    )

    @Argument(help: "ID of the stash to apply.")
    var stashID: String

    mutating func run() async throws {
        CLIRunner.handleApply(stashId: stashID)
    }
}

struct Drop: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "drop",
        abstract: "Remove a specific stash.",
        aliases: ["d"]
    )

    @Argument(help: "ID of the stash to remove.")
    var stashID: String

    mutating func run() async throws {
        CLIRunner.handleDrop(stashId: stashID)
    }
}

struct Clear: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "clear",
        abstract: "Remove all stashes."
    )

    mutating func run() async throws {
        CLIRunner.handleClear()
    }
}