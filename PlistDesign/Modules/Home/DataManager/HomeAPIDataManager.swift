//
//  HomeAPIDataManager.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 21/12/23.
//

import Foundation
protocol HomeAPIDataManagerProtocol {
    func fetchPlistData() async -> (PlistRootModel?, CustomError?)
}
class HomeAPIDataManager: HomeAPIDataManagerProtocol {

    let networkService: NetworkHandler?
    init(networkService: NetworkHandler) {
        self.networkService = networkService
    }
    func fetchPlistData() async -> (PlistRootModel?, CustomError?) {
        var plistModel: PlistRootModel?
        var plistError: CustomError?
        do {
            plistModel = try await networkService?.fetchData(for: PlistRootModel.self, from: APIConstant.shared.plistURL)
        } catch {
            plistError = error as? CustomError
        }
        return (plistModel, plistError)
    }
}
