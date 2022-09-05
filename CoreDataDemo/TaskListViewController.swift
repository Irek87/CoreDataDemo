//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Reek i on 31.08.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks = StorageManager.shared.fetchData()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupView()
    }
    
    // Setup View
    private func setupView() {
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    // Setup navigation bar
    private func setupNavigationBar() {
        
        // Set title for navigation bar
        title = "Task List"
        
        // Set large title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Bar Appearence
        if #available(iOS 13.0, *) {
            let navBarAppearence = UINavigationBarAppearance()
            navBarAppearence.configureWithOpaqueBackground()
            navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearence.backgroundColor = UIColor(
                red: 21/255,
                green: 101/255,
                blue: 192/255,
                alpha: 194/255
            )
            navigationController?.navigationBar.standardAppearance = navBarAppearence
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        }
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert()
    }
    
    private func save(task: String) {
        StorageManager.shared.save(task) { task in
            self.tasks.append(task)
            self.tableView.insertRows(
                at: [IndexPath(row: self.tasks.count - 1, section: 0)],
                with: .automatic
            )
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
}
 
// MARK: - UITableViewDelegate
extension TaskListViewController {
    
    // Edit task
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        showAlert(task: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Delete task
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.delete(task)
        }
    }
}

// MARK: - Alert controller
extension TaskListViewController {
    
    private func showAlert(task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit task" : "New task"
        
        let alert = AlertController(title: title, message: "What do you want to do?", preferredStyle: .alert)
        
        alert.action(task: task) { taskName in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task, newName: taskName)
                completion()
            } else {
                self.save(task: taskName)
            }
        }
        
        present(alert, animated: true)
    }
}
