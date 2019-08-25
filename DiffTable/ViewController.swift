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









//MARK: BASIC

/*
class NewViewController: UITableViewController {

	//MARK: iVars

    var dataSource: UITableViewDiffableDataSource<String, String>!

	var sections = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] {
		didSet {
			updateTableView()
		}
	}

	var people = [String]() {
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

	var currentTitle: String { sortAscending ? "A to Z" : "Z to A" }

	//MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpActionButtons()
		configureDataSource()
		sortAscending = true
    }

	override func viewDidAppear(_ animated: Bool) {
		 super.viewDidAppear(animated)
		 updateTableView()
	 }

	private func setUpActionButtons() {
		navigationItem.rightBarButtonItems = [
			UIBarButtonItem(image: .plus, style: .plain, target: self, action: #selector(add)),
			UIBarButtonItem(image: .minus, style: .plain, target: self, action: #selector(remove))
		]
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: .sort, style: .plain, target: self, action: #selector(sort))
	}

	//MARK: Table Set Up

	func configureDataSource() {

		let reuseIdentifier = "cellID"

		dataSource = UITableViewDiffableDataSource(
			tableView: tableView,
			cellProvider: {  tableView, indexPath, contact in
				let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
				cell.textLabel?.text = String(contact)
				cell.detailTextLabel?.text = "Section " + String(indexPath.section)
				return cell
			}
		)
    }

	func updateTableView() {
		currentSectionTitles.removeAll()
		var snapshot = NSDiffableDataSourceSnapshot<String, String>()

		sections.forEach { letter in
			let peopleForSection = people.filter({ $0.uppercased().hasPrefix(letter) })

			if !peopleForSection.isEmpty {
				snapshot.appendSections([letter])
				snapshot.appendItems(peopleForSection)
				currentSectionTitles.append(letter)
			}
		}

		dataSource.apply(snapshot, animatingDifferences: true)
	}

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UILabel()
        vw.backgroundColor = UIColor.lightGray
        vw.text = "  \(currentSectionTitles[section])"
        return vw
    }

	//MARK: Actions

    @objc func add() {
		let first = String("aflktrs".shuffled()).capitalized
		let last = String("bdefpodyh".shuffled()).capitalized
		people.append(first + " " + last)
	}

	@objc func sort() {
		sections.reverse()
		sortAscending.toggle()
	}

	@objc func remove() {
		if let ran = people.randomElement() {
			people.removeAll(where: { $0 == ran })
		}
	}
}

extension UIImage {
	static let plus = UIImage(systemName: "plus.circle")
	static let sort = UIImage(systemName: "arrow.up.arrow.down.circle")
	static let minus = UIImage(systemName: "minus.circle")
}

*/




//func loadData() {
//	let itemsPerSection = 5
//	//let sections = Array(0..<3)
//
//	var snapshot = NSDiffableDataSourceSnapshot<String, Int>()
//	var itemOffset = 0
//	sections.forEach {
//		snapshot.appendSections([$0])
//		snapshot.appendItems(Array(itemOffset..<itemOffset + itemsPerSection))
//		itemOffset += itemsPerSection
//	}
//
//	dataSource.apply(snapshot, animatingDifferences: true)
//}









//extension NewViewController {
//    enum Section: CaseIterable {
//        case a
//        case b
//        case c
//		case mean
//		case nice
//    }
//}
//
//struct Contact: Hashable {
//    var name: String
//    var email: String
//    var logo: String
//}
//
//struct ContactList {
//    var a: [Contact]
//    var b: [Contact]
//    var c: [Contact]
//	var mean: [Contact]
//	var nice: [Contact]
//}



/*
class NewViewController: UITableViewController {

    private lazy var dataSource = makeDataSource()

	var meanView = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource
        tableView.delegate = self

        title = "Test"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add)),
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(sort))
        ]

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))


//        loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    @objc func edit() {
        tableView.isEditing.toggle()
    }

    func makeDataSource() -> UITableViewDiffableDataSource<Section, Contact> {

        let reuseIdentifier = "cellID"

        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: {  tableView, indexPath, contact in

                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                cell.textLabel?.text = contact.logo + " " + contact.name
                cell.detailTextLabel?.text = contact.email
                return cell
            }
        )
    }

    func loadData() {
        let a = [
            Contact(name: "Tom", email: "Tom@myspace.com", logo: "😀"),
            Contact(name: "Bob", email: "Bob@gmail.com", logo: "😀")
        ]

        let b = [
            Contact(name: "Stev", email: "setev@aol.com", logo: "🐭"),
            Contact(name: "Mom", email: "mom@aol.com", logo: "🐭"),
            Contact(name: "Dad", email: "dad@aol.com", logo: "🐭")
        ]

        let c = [
            Contact(name: "Max", email: "max@something.com", logo: "⛑"),
            Contact(name: "Tim", email: "mason@something.com", logo: "⛑"),
            Contact(name: "Mason", email: "tim@something.com", logo: "⛑")
        ]

		let mean = [Contact]()
		let nice = [Contact]()

        let contactList = ContactList(a: a, b: b, c: c, mean: mean, nice: nice)
        update(with: contactList)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tappedItem = dataSource.itemIdentifier(for: indexPath)!
        print("You Tapped ", tappedItem)

        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected.toggle()
    }

    @objc func add() {

        let newFriends = [Contact(name: "Jane", email: "new@myspace.com", logo: "😀")]

        let newFam = [
            Contact(name: "Johnny", email: "harry@myspace.com", logo: "🐭"),
            Contact(name: "Alan", email: "harry@myspace.com", logo: "🐭"),
            Contact(name: "Smokie", email: "harry@myspace.com", logo: "🐭"),
            Contact(name: "Zmokie", email: "harry@myspace.com", logo: "🐭"),
            Contact(name: "YYhnny", email: "harry@myspace.com", logo: "🐭"),
            Contact(name: "Uan", email: "harry@myspace.com", logo: "🐭"),
            Contact(name: "Pmokie", email: "harry@myspace.com", logo: "🐭"),
            Contact(name: "Lmokie", email: "harry@myspace.com", logo: "🐭")
        ]
//
        var s = dataSource.snapshot()
        s.appendItems(newFriends, toSection: .mean)
        s.appendItems(newFam, toSection: .nice)

		meanView.toggle()

        dataSource.apply(s, animatingDifferences: true)
    }

    @objc func sort() {
//        let allItems = dataSource.snapshot().itemIdentifiers

		meanView.toggle()


		var mean = [Contact]()
		var nice = [Contact]()
		var a = [Contact]()
		var b = [Contact]()
		var c = [Contact]()

		if meanView {
			mean = dataSource.snapshot().itemIdentifiers(inSection: .mean)
			nice = dataSource.snapshot().itemIdentifiers(inSection: .nice)
			a = dataSource.snapshot().itemIdentifiers(inSection: .a)
			b = dataSource.snapshot().itemIdentifiers(inSection: .b)
			c = dataSource.snapshot().itemIdentifiers(inSection: .c)

		} else {
			mean = dataSource.snapshot().itemIdentifiers(inSection: .mean)
			nice = dataSource.snapshot().itemIdentifiers(inSection: .nice)
			a = dataSource.snapshot().itemIdentifiers(inSection: .a)
			b = dataSource.snapshot().itemIdentifiers(inSection: .b)
			c = dataSource.snapshot().itemIdentifiers(inSection: .c)
		}

		let s = dataSource.snapshot()

		dataSource.apply(s, animatingDifferences: true)

        let contactList = ContactList(a: a, b: b, c: c, mean: mean, nice: nice)
        update(with: contactList, animate: true)
    }

    func update(with list: ContactList, animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Contact>()
        snapshot.appendSections(Section.allCases)


        snapshot.appendItems(list.mean, toSection: .mean)
        snapshot.appendItems(list.nice, toSection: .nice)
        snapshot.appendItems(list.a, toSection: .a)
        snapshot.appendItems(list.b, toSection: .b)
        snapshot.appendItems(list.c, toSection: .c)


        dataSource.apply(snapshot, animatingDifferences: animate)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .destructive, title: "Bye Bye") { (_, _, done) in
            let item = self.dataSource.itemIdentifier(for: indexPath)!
            var s = self.dataSource.snapshot()
            s.deleteItems([item])
            self.dataSource.apply(s, animatingDifferences: true)

        }

        return UISwipeActionsConfiguration(actions: [action])
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UILabel()
        vw.backgroundColor = UIColor.lightGray
        vw.text = " Section Header \(section)"
        return vw
    }

//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let vw = UILabel()
//        vw.backgroundColor = UIColor.red
//        vw.text = "Section Footer \(section)"
//        return vw
//    }

//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return "Section Header \(section)"
//    }

//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        "Section Header \(section)"
//    }
//
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return ["sdsd", "sdsd", "oooo"]
//    }

//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		return "Section Header \(section)"
//    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
}

extension NewViewController {
    enum Section: CaseIterable {
        case a
        case b
        case c
		case mean
		case nice
    }
}

struct Contact: Hashable {
    var name: String
    var email: String
    var logo: String
}

struct ContactList {
    var a: [Contact]
    var b: [Contact]
    var c: [Contact]
	var mean: [Contact]
	var nice: [Contact]
}

*/
