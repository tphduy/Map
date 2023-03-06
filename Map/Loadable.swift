//
//  Loadable.swift
//  Map
//
//  Created by Duy Tran on 27/02/2023.
//

import Foundation

/// An enumeration that represents states of loading data with latency.
enum Loadable<Data, Failure> where Failure: Error {
    /// The data is being reloaded with the latest data.
    case isLoading(last: Data?)
    /// The data is loaded successfully.
    case loaded(Data)
    /// The data loading failed.
    case failed(Failure)

    var data: Data? {
        switch self {
        case .isLoading(let data):
            return data
        case .loaded(let data):
            return data
        case .failed:
            return nil
        }
    }

    var error: Error? {
        switch self {
        case .isLoading, .loaded:
            return nil
        case .failed(let error):
            return error
        }
    }
}
