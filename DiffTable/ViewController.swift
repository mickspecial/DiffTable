//
//  ViewController.swift
//  DiffTable
//
//  Created by Michael Schembri on 29/6/19.
//  Copyright © 2019 Michael Schembri. All rights reserved.
//

import UIKit

class NewViewController: UITableViewController {

	//MARK: iVars

    var dataSource: UITableViewDiffableDataSource<String, Person>!

	var alphabelticalSections = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] {
		didSet {
			updateTableView()
		}
	}

	var people = [Person]() {
		didSet {
			updateTableView()
		}
	}

	var currentSectionTitles = [String]()

	var sortAscending = true {
		didSet {
			title = currentTitle
		}
	}

	var currentTitle: String {
		if sortingStyle == .team {
			return "By Team"
		} else {
			return sortAscending ? "A to Z" : "Z to A"
		}
	}

	var sortingStyle = SortBy.name  {
		didSet {
			title = currentTitle
			updateTableView()
		}
	}

	enum SortBy {
		case name, team
	}

	//MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpActionButtons()
		configureDataSource()
		sortAscending = true
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// add dummy people
		for _ in (0...6) { add() }
		updateTableView()
	 }

	private func setUpActionButtons() {
		navigationItem.rightBarButtonItems = [
			UIBarButtonItem(image: .plus, style: .plain, target: self, action: #selector(add)),
			UIBarButtonItem(image: .minus, style: .plain, target: self, action: #selector(remove))
		]

		navigationItem.leftBarButtonItems = [
			UIBarButtonItem(image: .sort, style: .plain, target: self, action: #selector(sortByName)),
			UIBarButtonItem(image: .people, style: .plain, target: self, action: #selector(sortByTeam))
		]
	}

	//MARK: Table

	func configureDataSource() {

		let reuseIdentifier = "cellID"

		dataSource = UITableViewDiffableDataSource(
			tableView: tableView,
			cellProvider: {  tableView, indexPath, person in
				let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
				cell.textLabel?.text = person.name
				cell.detailTextLabel?.text = "●"
				cell.detailTextLabel?.textColor = person.team.iconColor
				return cell
			}
		)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UILabel()
        vw.backgroundColor = UIColor.lightGray
        vw.text = "  \(currentSectionTitles[section])"
        return vw
    }

	func updateTableView() {
		currentSectionTitles.removeAll()

		switch sortingStyle {
		case .name: dataSource.apply(sortTableByName(), animatingDifferences: true)
		case .team: dataSource.apply(sortTableByTeam(), animatingDifferences: true)
		}
	}

	//MARK: Sorting

	private func sortTableByName() -> NSDiffableDataSourceSnapshot<String, Person> {

		var snapshot = NSDiffableDataSourceSnapshot<String, Person>()

		alphabelticalSections.forEach { letter in
			let peopleForSection = people.filter({ $0.name.uppercased().hasPrefix(letter) })

			if !peopleForSection.isEmpty {
				snapshot.appendSections([letter])
				snapshot.appendItems(peopleForSection)
				currentSectionTitles.append(letter)
			}
		}

		return snapshot
	}

	private func sortTableByTeam() -> NSDiffableDataSourceSnapshot<String, Person> {

		var snapshot = NSDiffableDataSourceSnapshot<String, Person>()

		Team.allCases.forEach { team in
			let peopleForSection = people.filter({ $0.team == team })

			if !peopleForSection.isEmpty {
				snapshot.appendSections([team.rawValue.capitalized])
				snapshot.appendItems(peopleForSection)
				currentSectionTitles.append(team.rawValue.capitalized)
			}
		}

		return snapshot
	}
	//MARK: Actions

    @objc func add() {
		people.append(Person.randomPerson())
	}

	@objc func sortByName() {
		sortingStyle = .name
		alphabelticalSections.reverse()
		sortAscending.toggle()
	}

	@objc func sortByTeam() {
		sortingStyle = .team
	}

	@objc func remove() {
		if let ran = people.randomElement() {
			people.removeAll(where: { $0 == ran })
		}
	}
}

//MARK: Helpers

extension UIImage {
	static let plus = UIImage(systemName: "plus.circle")!
	static let people = UIImage(systemName: "person.circle")!
	static let sort = UIImage(systemName: "arrow.up.arrow.down.circle")!
	static let minus = UIImage(systemName: "minus.circle")!
}

extension String {
	static func randomName() -> String {
		let first = Int.random(in: 2..<6)
		let last = Int.random(in: 2..<8)
		return String.randomString(first).capitalized + " " + String.randomString(last).capitalized
	}

	static func randomString(_ length: Int) -> String {
	  let letters = "abcdefghijklmnopqrstuvwxyz"
	  return String((0..<length).map{ _ in letters.randomElement()! })
	}
}

//MARK: Models

struct Person: Hashable {
	let name: String
	let team: Team

	static func randomPerson() -> Person {
		return Person(name: String.randomName(), team: Team.allCases.randomElement()!)
	}
}

enum Team: String, CaseIterable {
	case blue, green, red

	var iconColor: UIColor {
		switch self {
		case .blue: return UIColor.blue
		case .green: return UIColor.green
		case .red: return UIColor.red
		}
	}
}
