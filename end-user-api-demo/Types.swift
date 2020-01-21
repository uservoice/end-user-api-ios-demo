//  Types.swift
//  end-user-api-demo

import Foundation

struct Forum: Decodable {
    var id: Int
    var name: String
    var welcome_message: String
    var prompt: String
}

struct Idea: Decodable {
    var id: Int
    var title: String
    var text: String?
    var voted: Bool?
}
