//
//  NoteListTableViewController.swift
//  iosbeltexam
//
//  Created by Vineeth Raghunath on 5/24/17.
//  Copyright © 2017 Vineeth Raghunath. All rights reserved.
//

import UIKit
import CoreData

class NoteListTableViewController: UITableViewController {

    var notes = Array<Note>()
    var filteredNotes = Array<Note>()
    var searchController = UISearchController(searchResultsController: nil)
    
    //Managed Object Context
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //IB Action
    @IBAction func composeBtnPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "NoteDetailSegue", sender: nil)
    }
    
    //On view load, add search bar and fetch all notes
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllNotes()
        tableView.tableHeaderView = searchController.searchBar;
        //definesPresentationContext = true
        searchController.searchResultsUpdater = self;
        searchController.dimsBackgroundDuringPresentation = false
    }
    
    //View will appear - before view appears fetch all notes and reload tableview
    override func viewWillAppear(_ animated: Bool) {
        fetchAllNotes()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    //Set number of rows in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredNotes.count
        }
        
        return notes.count
    }
    
    //Set cell data for table rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        let note: Note
        
        //If search bar is active, use filtered notes array to populate rows. Otherwise use "unfiltered" notes
        if searchController.isActive && searchController.searchBar.text != "" {
            note = filteredNotes[indexPath.row]
        } else {
            note = notes[indexPath.row]
        }
        
        //Change main label on cell to note detail
        cell.textLabel?.text = note.detail
        
        //Change detail label on cell to note edited date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: note.date! as Date)
        let tempDate = formatter.date(from: dateString)
        formatter.dateFormat = "MM-dd-yyyy"
        let noteDate = formatter.string(from: tempDate!)
        cell.detailTextLabel?.text = noteDate
        
        return cell
    }
    
    //Perform segue if table row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //set search controller to inactive to prevent search bar from displaying on note details view
        searchController.isActive = false
        
        performSegue(withIdentifier: "NoteDetailSegue", sender: notes[indexPath.row])
    }
    
    //Delete row and corresponding note if selected
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt
        indexPath: IndexPath) {
        
        //If search bar is active, delete from both the filtered notes and unfiltered notes array.
        if searchController.isActive && searchController.searchBar.text != "" {
            let deleteNote = filteredNotes[indexPath.row]
            let noteIndex = notes.index(of: deleteNote)
            
            moc.delete(deleteNote)
            
            saveItem()
            filteredNotes.remove(at: indexPath.row)
            notes.remove(at: noteIndex!)
        } else {
            let deleteNote = notes[indexPath.row]
            moc.delete(deleteNote)
            
            saveItem()
            notes.remove(at: indexPath.row)
        }
        
        tableView.reloadData()
    }
    
    
    //CoreData - fetch all notes
    func fetchAllNotes() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let result = try moc.fetch(request)
            notes = result as! Array<Note>
        } catch {
            print(error)
        }
    }
    
    //CoreData - save all notes
    func saveItem() {
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    //Prep for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NoteDetailSegue" {
            if sender != nil {
                let controller = segue.destination as! NoteDetailViewController
                controller.note = sender as? Note
            }
        }
    }
}

//SearchBar Delegate functions/code
extension NoteListTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    //Use text from search bar to filter results displayed in the table
    func updateSearchResults(for searchController: UISearchController) {
        //set filtered notes array to contain all notes which have the string entered by the user
        filteredNotes = notes.filter({
            note in return (note.detail?.localizedLowercase.localizedStandardContains(searchController.searchBar.text!.lowercased()))!
        })
        
        tableView.reloadData()
    }
}
