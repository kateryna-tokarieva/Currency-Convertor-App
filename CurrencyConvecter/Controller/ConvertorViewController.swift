//
//  ViewController.swift
//  CurrencyConvecter
//
//  Created by Екатерина Токарева on 19/01/2023.
//

import UIKit
import CoreData

final class ConvertorViewController: UIViewController {
    
    @IBOutlet private weak var buyButton: UIButton!
    @IBOutlet private weak var sellButton: UIButton!
    @IBOutlet private weak var currencyView: UIView!
    @IBOutlet private weak var baseCurrencyTextField: UITextField!
    @IBOutlet private weak var firstExchangeCurrencyTextField: UITextField!
    @IBOutlet private weak var secondExchangeCurrencyTextField: UITextField!
    @IBOutlet private weak var updateDateLabel: UILabel!
    @IBOutlet private weak var baseCurrencyLabel: UILabel!
    @IBOutlet private weak var firstExchangeCurrencyLabel: UILabel!
    @IBOutlet private weak var secondExchangeCurrencyLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    private var rates: [LatestRate] = []
    private lazy var updateTime: [UpdateTime] = []
    private var currencyRatesService = CurrencyRatesService()
    private var timer: Timer?
    private var stateIsInitial = true
    private var optionIsBuy = true
    private lazy var activeTextField = baseCurrencyTextField
    private var persistenceContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
    private var currentTime: Date {
        Date()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        baseCurrencyTextField.delegate = self
        firstExchangeCurrencyTextField.delegate = self
        secondExchangeCurrencyTextField.delegate = self
    }
    
    @objc private func refresh(refreshControl: UIRefreshControl) {
        self.updateData()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataIfNeeded()
        if updateTime.hourHasPassed {
            updateData()
        }
        setupInitialUI()
    }
    
    private func updateDataIfNeeded() {
        if let context = persistenceContext {
            let ratesFetchRequest: NSFetchRequest<LatestRate> = LatestRate.fetchRequest()
            do {
                rates = try context.fetch(ratesFetchRequest)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            let timeFetchRequest: NSFetchRequest<UpdateTime> = UpdateTime.fetchRequest()
            
            do {
                updateTime = try context.fetch(timeFetchRequest)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateData() {
        currencyRatesService.fetchExchangeRate { [weak self] convertorData in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let data = convertorData[0]
                self.saveRates(baseCurrency: data.baseCurrency,
                               exchangeCurrency: data.exchangeCurrency,
                               sellRate: data.sellRate,
                               buyRate: data.buyRate)
                let data2 = convertorData[1]
                self.saveRates(baseCurrency: data2.baseCurrency,
                               exchangeCurrency: data2.exchangeCurrency,
                               sellRate: data2.sellRate,
                               buyRate: data2.buyRate)
                self.saveUpdateTime(time: self.currentTime)
                self.updateUI()
            }
        }
    }
    
    private func saveRates(baseCurrency: String,
                           exchangeCurrency: String,
                           sellRate: String,
                           buyRate: String) {
        
        guard let context = persistenceContext else { return }
        if let rate = rates.first,
           rates.count > 1 {
            context.delete(rate)
            rates.removeFirst()
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "LatestRate", in: context) else { return }
        let dataObject = LatestRate(entity: entity, insertInto: context)
        dataObject.baseCurrency = baseCurrency
        dataObject.exchangeCurrency = exchangeCurrency
        dataObject.buyRate = Double(buyRate) ?? 0
        dataObject.sellRate = Double(sellRate) ?? 0
        do {
            try context.save()
            rates.append(dataObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    private func saveUpdateTime(time: Date) {
        guard let context = persistenceContext else { return }
        if let time = updateTime.first {
            context.delete(time)
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "UpdateTime", in: context) else { return }
        let dataObject = UpdateTime(entity: entity, insertInto: context)
        dataObject.time = time
        do {
            try context.save()
            updateTime.removeAll()
            updateTime.append(dataObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func setupInitialUI() {
        currencyView.layer.shadowOffset = Constants.shadowOffset
        currencyView.layer.shadowColor = Constants.shadowColor
        currencyView.layer.shadowRadius = Constants.shadowRadius
        currencyView.layer.shadowOpacity = Constants.shadowOpacity
        currencyView.layer.cornerRadius = Constants.cornerRadius
        currencyView.clipsToBounds = true
        currencyView.layer.masksToBounds = false
        buyButton.layer.cornerRadius = Constants.buttonCornerRadius
        sellButton.layer.cornerRadius = Constants.buttonCornerRadius
        buyButton.clipsToBounds = true
        sellButton.clipsToBounds = true
        updateButtonUI(activeButton: buyButton)
        if let time = self.updateTime.last?.time {
            updateDateLabel.text = time.formatted
        }
    }
    
    private func updateUI() {
        if optionIsBuy {
            updateButtonUI(activeButton: buyButton)
        } else {
            updateButtonUI(activeButton: sellButton)
        }
        if let time = self.updateTime.last?.time {
            updateDateLabel.text = time.formatted
        }
    }
    
    
    private func updateButtonUI(activeButton: UIButton) {
        let inactiveButton = activeButton == sellButton ? buyButton : sellButton
        activeButton.backgroundColor = Constants.activeButtonColor
        activeButton.titleLabel?.tintColor = Constants.activeButtonTextColor
        inactiveButton?.backgroundColor = Constants.inactiveButtonColor
        inactiveButton?.titleLabel?.tintColor = Constants.inactiveButtonTextColor
    }
    
    private func getMessageToShare() -> String {
        var message = "Current rates:\n"
        for rate in rates {
            message.append("\((rate.baseCurrency ?? "") as String) to \((rate.exchangeCurrency ?? "") as String):\nBuy - \(rate.buyRate)\nSell - \(rate.sellRate)\n")
        }
        return message
    }
    
    private func showResult() {
        var textFieldsArray = [baseCurrencyTextField, firstExchangeCurrencyTextField, secondExchangeCurrencyTextField]
        let currencyCode = textFieldsArray.firstIndex(of: activeTextField) ?? 0
        textFieldsArray.remove(at: currencyCode)
        let amount = Double(activeTextField?.text ?? "0") ?? 0
        let exchangeService = ExchangeService()
        let results = exchangeService.exchange(optionIsBuy: optionIsBuy, amount: amount, rates: rates, currencyCode: currencyCode)
        textFieldsArray[0]?.text = String(format:"%.2f", results.0)
        textFieldsArray[1]?.text = String(format:"%.2f", results.1)
    }
    
    @IBAction private func sellButtonPressed() {
        optionIsBuy = false
        showResult()
        updateUI()
    }
   
    @IBAction private func buyButtonPressed() {
        optionIsBuy = true
        showResult()
        updateUI()
    }
    
    private func editingChanged(text: String?) {
        stateIsInitial = true
        updateUI()
        guard let text = text else { return }
        guard !text.isEmpty else { return}
        stateIsInitial = false
        updateUI()
    }
    
    @IBAction private func baseCurrencyEditingChanged() {
        let text = baseCurrencyTextField.text
        editingChanged(text: text)
    }
    
    @IBAction func firstCurrencyEditingChanged() {
        let text = firstExchangeCurrencyTextField.text
        editingChanged(text: text)
    }
    
    @IBAction func secondCurrencyEditingChanged() {
        let text = secondExchangeCurrencyTextField.text
        editingChanged(text: text)
    }
    
    @IBAction private func shareButtonAction() {
        let activityVC = UIActivityViewController(activityItems: [getMessageToShare()], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.popoverPresentationController?.sourceRect = CGRectMake(0, 20, 150, 100)
        self.present(activityVC, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

extension ConvertorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        showResult()
        updateUI()
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits.union (CharacterSet (charactersIn: "."))
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = Constants.activeTextFieldColor
        textField.layer.cornerRadius = 6
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
    }
    
}

private extension ConvertorViewController {
    
    struct Constants {
        static let shadowRadius: CGFloat = 4
        static let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let shadowOpacity: Float = 1
        static let cornerRadius: CGFloat = 10
        static let buttonCornerRadius: CGFloat = 6
        static let activeButtonColor = UIColor.systemBlue
        static let activeButtonTextColor = UIColor.white
        static let inactiveButtonColor = UIColor.white
        static let inactiveButtonTextColor = UIColor(red: 0, green: 0.19, blue: 0.4, alpha: 1)
        static let activeTextFieldColor = UIColor.systemBlue.cgColor
        static let  buttonBoarderWidth: CGFloat = 1
        static let textFieldBoarderWidth: CGFloat = 1
        static let textFieldCornerRadius: CGFloat = 5
    }
}
