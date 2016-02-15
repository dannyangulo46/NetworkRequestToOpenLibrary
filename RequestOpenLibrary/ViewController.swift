//
//  ViewController.swift
//  RequestOpenLibrary
//
//  Created by Danny Angulo on 2/11/16.
//  Copyright © 2016 BajaCalApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var buttonClearText: UIButton!
    
    @IBOutlet weak var textToSearh: UITextField!
    
    
    @IBOutlet weak var textOutput: UITextView!
    
    
    // Mark: VIEWCONTROLLER LIFE CYCLE
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    
    }
    
    
    // Mark: - TEXTFIELD DELEGATES
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField.text?.characters.count<13) { // Check if the ISBN as 13 numbers
            textOutput.text = "Al ISBN le faltan mas numeros, deben de ser 13"
        
        } else {
            asyncNetworkRequest(addDashesToISBN(textField.text!))
        }
        
        
        return true
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if string.characters.count == 0 {
            return true
        }
        
        let currentText = textField.text ?? ""
        
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if prospectiveText.containsOnlyCharactersIn("0123456789") && prospectiveText.characters.count < 14 {
            
            return true
        }
        
        
     return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    
    // Mark: - HELPER FUNCTIONS

    func syncNetworkRequest() {
     
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:978-84-376-0494-7"
        
        let url = NSURL(string: urls)

        let data = NSData(contentsOfURL: url!)
        
        let text = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        textOutput.text = text as? String
        //print("Termino")
    }
    
    func asyncNetworkRequest(isbn: String) {
        
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + isbn
        
        let url = NSURL(string: urls)
        let session = NSURLSession.sharedSession()
        
        
        let block = { (data: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
            
       
                   let text = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        if error==nil {
                            if data==nil {
                                self.textOutput.text = "No existe ese numero ISBN"
                            } else {
                                self.textOutput.text = text! as String
                            }
                        } else {
                        
                            self.textOutput.text = "Hubo un error con la peticio al servidor"
                        }
                    })
                }
        
        let dt = session.dataTaskWithURL(url!, completionHandler: block)
        dt.resume()

    }
    
    func addDashesToISBN(ISBN: String) -> String{
    
        var myISBN = ISBN
        
        let index1 = myISBN.startIndex.advancedBy(12)
        let index2 = myISBN.startIndex.advancedBy(8)
        let index3 = myISBN.startIndex.advancedBy(5)
        let index4 = myISBN.startIndex.advancedBy(3)
        
        
        myISBN.insert("-", atIndex: index1)
        myISBN.insert("-", atIndex: index2)
        myISBN.insert("-", atIndex: index3)
        myISBN.insert("-", atIndex: index4)

        
        return myISBN
    }
}

extension String {


    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersInString: matchCharacters).invertedSet
        return self.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
    }


    
    
}


