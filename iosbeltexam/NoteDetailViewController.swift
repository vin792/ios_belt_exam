//
//  NoteDetailViewController.swift
//  iosbeltexam
//
//  Created by Vineeth Raghunath on 5/24/17.
//  Copyright © 2017 Vineeth Raghunath. All rights reserved.
//

import UIKit
import CoreData

class NoteDetailViewController: UIViewController, UITextViewDelegate {

    var note: Note?
    
    //Managed Object Context
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //IB Outlet
    @IBOutlet weak var noteTextField: UITextView!
    
    //View load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If editing note, preset text fieldnote text
        if let noteText = note {
            noteTextField.text = noteText.detail
        }
        
        //If creating new note, create new note object
        if note == nil {
            note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: moc) as? Note
        }
        
        noteTextField.delegate = self
    }
    
    //Delete new note object when view is dismissed and user has not edited the newly created note
    override func viewWillDisappear(_ animated: Bool) {
        if note?.date == nil {
            moc.delete(note!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //When user edits the text view, add text and updated date to note object and save note
    func textViewDidChange(_ textView: UITextView) {
        if self.noteTextField.text != "" {
            note?.detail = self.noteTextField.text
            note?.date = Date() as NSDate
            saveNote()
        }
    }
    
    //CoreData - save note
    func saveNote() {
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
}
