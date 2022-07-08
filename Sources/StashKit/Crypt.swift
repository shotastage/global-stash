//
//  Crypt.swift
//  
//
//  Created by Shota Shimazu on 2022/07/05.
//

import Foundation


class FileCrypt {
    func genSecretkey(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let numbers = "0123456789"
        let symbols = "~!@#$%^&*()-+_}]{[?/>.<,"

        var randomString = ""
        for _ in 0 ..< length {
            randomString += String("\(letters)\(numbers)\(symbols)".randomElement()!)
        }
        return randomString
    }
}
