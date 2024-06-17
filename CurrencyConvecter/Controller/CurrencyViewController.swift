//
//  CurrencyViewController.swift
//  CurrencyConvecter
//
//  Created by Екатерина Токарева on 21/01/2023.
//

import UIKit

final class CurrencyViewController: UITableViewController {
    private struct Section {
        let letter: String
        let currencies: [String]
    }
    private var sections = [Section]()
    private var filteredCurrencies: [String] = []
    private var currenciesArray: [String] = []
    private var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }
    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Currencies"
        return searchController
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        readJson()
        setupDataSource()
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupDataSource() {
        var sections = [Section]()
        let uniqueLetters = Set(currenciesArray.map { String($0.prefix(1)) })
        for letter in uniqueLetters.sorted() {
            let linesForLetter = currenciesArray.filter { String($0.prefix(1)) == letter }
            sections.append(Section(letter: letter, currencies: linesForLetter.sorted()))
        }
        self.sections = sections
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredCurrencies = currenciesArray.filter { (currency: String) -> Bool in
            return currency.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    private func readJson() {
        guard let file = Bundle.main.url(forResource: "ListOfCurrencies", withExtension: "json") else { return }
        var json: Any?
        do {
            let data = try Data(contentsOf: file)
            json = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            print(error.localizedDescription)
        }
        if let object = json as? [String] {
            currenciesArray = object
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        filteredCurrencies.isEmpty ? sections.count : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredCurrencies.count : sections[section].currencies.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        isFiltering ? [""] : sections.map { $0.letter }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        isFiltering ? "" : sections[section].letter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        let currency: String
        if isFiltering {
            currency = filteredCurrencies[indexPath.row]
            cell.textLabel?.text = currency
        } else {
            let section = sections[indexPath.section]
            let currency = section.currencies[indexPath.row]
            cell.textLabel?.text = currency
        }
        return cell
    }
}

extension CurrencyViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text ?? "")
    }
}
