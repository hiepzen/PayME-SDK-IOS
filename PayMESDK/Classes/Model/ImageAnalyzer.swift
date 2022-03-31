//
//  ImageAnalyzer.swift
//  PayMESDK
//
//  Created by Nam Phan Thanh on 24/03/2022.
//

import Foundation
#if canImport(Vision)
import Vision

protocol ImageAnalyzerProtocol: AnyObject {
    func didFinishAnalyzation(with result: Swift.Result<CreditCard, CreditCardScannerError>)
}

@available(iOS 13, *)
final class ImageAnalyzer {
    enum Candidate: Hashable {
        case number(String), name(String)
        case expireDate(DateComponents), validDate(DateComponents)
    }

    typealias PredictedCount = Int

    private var selectedCard = CreditCard()
    private var predictedCardInfo: [Candidate: PredictedCount] = [:]
    private weak var delegate: ImageAnalyzerProtocol?

    init(delegate: ImageAnalyzerProtocol) {
        self.delegate = delegate
    }

    // MARK: - Vision-

    public lazy var request = VNRecognizeTextRequest(completionHandler: requestHandler)

    func analyze(image: CGImage) {
        let requestHandler = VNImageRequestHandler(
                cgImage: image,
                orientation: .up,
                options: [:]
        )

        do {
            try requestHandler.perform([request])
        } catch {
            let e = CreditCardScannerError(kind: .photoProcessing, underlyingError: error)
            delegate?.didFinishAnalyzation(with: .failure(e))
            delegate = nil
        }
    }

    lazy var requestHandler: ((VNRequest, Error?) -> Void)? = { [weak self] request, _ in
        guard let strongSelf = self else { return }

        let creditCardNumber: Regex = #"(?:\d[ -]*?){16,19}"#
        let month: Regex = #"(\d{2})\/\d{2}"#
        let year: Regex = #"\d{2}\/(\d{2})"#
        let wordsToSkip = ["mastercard", "jcb", "visa", "express", "bank", "card", "platinum", "reward"]
        // These may be contained in the date strings, so ignore them only for names
        let invalidNames = ["expiration", "valid", "since", "from", "until", "month", "year"]
        let name: Regex = #"([A-z]{2,}\h([A-z.]+\h)?[A-z]{2,})"#

        let prefixes = ["9704","4","51","52", "53", "54", "55", "2221", "2229", "223", "229", "23", "26", "270", "271", "2720", "2131", "1800", "35"]

        guard let results = request.results as? [VNRecognizedTextObservation] else { return }

        var creditCard = CreditCard(number: nil, name: nil, expireDate: nil, validDate: nil)

        let maxCandidates = 1
        for result in results {
            guard
                    let candidate = result.topCandidates(maxCandidates).first,
                    candidate.confidence > 0.1
                    else { continue }

            let string = candidate.string
            let containsWordToSkip = wordsToSkip.contains { string.lowercased().contains($0) }
            if containsWordToSkip { continue }

            if (creditCardNumber.hasMatch(in: string) && (
                    prefixes.contains(where: string.hasPrefix)
            )) {
                creditCard.number = string.replacingOccurrences(of: " ", with: "")
                        .replacingOccurrences(of: "-", with: "")
            } else if let month = month.captures(in: string).last.flatMap(Int.init),
                      let year = year.captures(in: string).last.flatMap({ Int("20" + $0) }) {

                if creditCard.validDate == nil {
                    creditCard.validDate = DateComponents(year: year, month: month)
                } else {

                }

            } else if let name = name.firstMatch(in: string) {
                let containsInvalidName = invalidNames.contains { name.lowercased().contains($0) }
                if containsInvalidName { continue }
                creditCard.name = name
            } else {
                continue
            }
        }

        // Name
        if let name = creditCard.name {
            let count = strongSelf.predictedCardInfo[.name(name), default: 0]
            strongSelf.predictedCardInfo[.name(name)] = count + 1
            if count > 2 {
                strongSelf.selectedCard.name = name
            }
        }
        // ExpireDate
        if let date = creditCard.expireDate {
            let count = strongSelf.predictedCardInfo[.expireDate(date), default: 0]
            strongSelf.predictedCardInfo[.expireDate(date)] = count + 1
            if count > 2 {
                strongSelf.selectedCard.expireDate = date
            }
        }
        // ValidDate
        if let date = creditCard.validDate {
            let count = strongSelf.predictedCardInfo[.validDate(date), default: 0]
            strongSelf.predictedCardInfo[.validDate(date)] = count + 1
            if count > 2 {
                strongSelf.selectedCard.validDate = date
            }
        }
        // Number
        if let number = creditCard.number {
            let count = strongSelf.predictedCardInfo[.number(number), default: 0]
            strongSelf.predictedCardInfo[.number(number)] = count + 1
            if count > 2 {
                strongSelf.selectedCard.number = number
            }
        }

        let strongCond = strongSelf.selectedCard.number != nil
                && (strongSelf.selectedCard.expireDate != nil
                || strongSelf.selectedCard.validDate != nil)

        if strongSelf.selectedCard.number != nil
                   && (strongSelf.selectedCard.expireDate != nil
                || strongSelf.selectedCard.validDate != nil) {
            strongSelf.delegate?.didFinishAnalyzation(with: .success(strongSelf.selectedCard))
            strongSelf.delegate = nil
        }
    }
}
#endif