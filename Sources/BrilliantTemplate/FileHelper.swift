//
// Created by Ubaldo Cotta on 12/11/16.
//

import Foundation




#if os(Linux)
// realpath is not working in linux
func loadfile(file:String, in path:String) -> String {
    func containsTraversalCharacters(data:String) -> Bool {
        let dangerCharacters = ["%2e", "%2f", "%5c", "%25", "%c0%af", "%c1%9c", ":", ">", "<", "./", ".\\", "..", "\\\\", "//", "/.", "\\.", "|"]
        return (dangerCharacters.filter { data.contains($0) }.flatMap { $0 }).count > 0
    }

    var result = "cannot open file \(file)"

    let tmp = path + "/" + file
    do {
        if !containsTraversalCharacters(data:tmp) {
            result = try String(contentsOfFile: tmp, encoding: String.Encoding.utf8)
        }
    } catch {
    }
    return result
}
#else
func loadfile(file:String, in path:String) -> String {
    func rp(path: String) -> String? {
        let p = realpath(path, nil)
        if p == nil {
            return nil
        }
        defer { free(p) }

        return String(validatingUTF8: p!)
    }

    let tmp = path + "/" + file
    var result = "cannot open file \(file)"
    do {
        if let file = rp(path: tmp) {
            if file.hasPrefix(path) {
                result = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
            } else {
                print("Trying to acces file: \(file) outside path \(path)")
            }
        }
    } catch {}
    return result
}
#endif



