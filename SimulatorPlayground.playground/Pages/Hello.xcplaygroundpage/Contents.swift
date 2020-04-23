import Cocoa

var str = "Hello, playground"

var dict: [Int: String] = [:]

dict[3]

func memoize<T:Hashable, U>(function: @escaping (T) -> U) -> ((T) -> (U)) {
    var cache = [T: U]()
    return { input in
        if let cached = cache[input] { print("HIT \(cached)"); return cached }
        let result = function(input)
        cache[input] = result
        return result
    }
}

func square(_ n: Int) -> Int { return n * n }
var memoizedSquare = memoize(function: square)

memoizedSquare(5)
memoizedSquare(5)
memoizedSquare(3)
memoizedSquare(3)
