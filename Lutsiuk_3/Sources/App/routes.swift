import Vapor

func countWords(_ words: [String], intoCores cores: Int) -> [[String: Int]] {
    let coresSize = words.count / cores
    var wordCores: [[String]] = []
    for i in 0..<cores {
        let startIndex = i * coresSize
        let endIndex = (i == cores - 1) ? words.count : startIndex + coresSize
        wordCores.append(Array(words[startIndex..<endIndex]))
    }

    var wordCount: [[String: Int]] = []
    for core in wordCores {
        var coreWordCount: [String: Int] = [:]
        for word in core {
            if let count = coreWordCount[word] {
                coreWordCount[word] = count + 1
            } else {
                coreWordCount[word] = 1
            }
        }
        wordCount.append(coreWordCount)
    }

    var result: [String: Int] = [:]
    for coreWordCount in wordCount {
        for (word, count) in coreWordCount {
            if let existingCount = result[word] {
                result[word] = existingCount + count
            } else {
                result[word] = count
            }
        }
    }

    return [result]
}

func countWordsMapReduce(_ words: [String], intoCores cores: Int) -> [String: Int] {
    let coreSize = words.count / cores
    let wordCores = (0..<cores).map { i in
        let startIndex = i * coreSize
        let endIndex = (i == cores - 1) ? words.count : startIndex + coreSize
        return Array(words[startIndex..<endIndex])
    }

    let wordCount = wordCores.map { core in
        return Dictionary(grouping: core, by: { $0 }).mapValues { $0.count }
    }

    let result = wordCount.reduce(into: [String: Int]()) { result, coreWordCount in
        for (word, count) in coreWordCount {
            result[word, default: 0] += count
        }
    }

    return result
}


func routes(_ app: Application) throws {
    app.post("wordcount", "simple") { req -> [String: Int] in
        let words = try req.content.get(String.self, at: "words")
        let cores = try req.content.get(Int.self, at: "cores")

        let wordsArray = words.components(separatedBy: ",")
        let result = countWords(wordsArray, intoCores: cores)

        return result[0]
    }

    app.post("wordcount", "map_reduce") { req -> [String: Int] in
        let words = try req.content.get(String.self, at: "words")
        let cores = try req.content.get(Int.self, at: "cores")

        let wordsArray = words.components(separatedBy: ",")
        let result = countWordsMapReduce(wordsArray, intoCores: cores)

        return result
    }
}
