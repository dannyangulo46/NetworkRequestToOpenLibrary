//
//  ViewController.swift
//  RequestOpenLibrary
//
//  Created by Danny Angulo on 2/11/16.
//  Copyright © 2016 BajaCalApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {


    
    @IBOutlet weak var textToSearh: UITextField!
   
    @IBOutlet weak var lblMessageToUser: UILabel!
    
    @IBOutlet weak var imageViewBookPicture: UIImageView!
    
    @IBOutlet weak var lblDisplayTitle: UILabel!
    
    @IBOutlet weak var lblDisplayAuthor: UILabel!
    
    
    // Mark: VIEWCONTROLLER LIFE CYCLE
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imageViewBookPicture.contentMode = .ScaleAspectFit
    
    
    }
    
    
    // Mark: - TEXTFIELD DELEGATES
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        lblMessageToUser.text = ""
        lblDisplayTitle.text = ""
        imageViewBookPicture.image = nil
        
        
        
        if (textField.text?.characters.count<13) { // Check if the ISBN as 13 numbers
            lblMessageToUser.text = "Al ISBN le faltan mas numeros, deben de ser 13"
        
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
    
    // 9780060833459 The effective executive, Peter Drucker
    // 9780517549780
    
    
    func asyncNetworkRequest(isbn: String) {
        
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + isbn
        
        
        let url = NSURL(string: urls)
        let session = NSURLSession.sharedSession()
        
        
        let block = { (data: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
            
            guard (error == nil) else {
                self.showError()
                return
            }
       
            do {
             
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves)
                
                let dic1 = json as! NSDictionary
                let isbn1 = "ISBN:"+isbn
                let dic2 = dic1[isbn1] as! NSDictionary
                let title = dic2["title"] as! NSString as String
                self.updateTitle(title)
                
                let authors = dic2["authors"] as! [[String:AnyObject]]
                
                
                
                var i = 0
                var allAuthors:String?
                for author in authors {
                    
                    i++
                    let authorName = author["name"] as! String
                    
                    if i==1 {
                            allAuthors = authorName
                        
                    } else {
                        
                        allAuthors = allAuthors! + "; " + authorName
                    }
                    
                    
                    print(allAuthors)
                    
                }
                
                //Update UI with Authors names
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.lblDisplayAuthor.text = allAuthors
                    
                }
                
                guard let imageDic = dic2["cover"] as? NSDictionary else {
                    print("Book does not have an image")
                    return
                }
                
                
                guard let imageURLString = imageDic["large"] as? String else {
                    print("Book does not have a large image")
                    return
                }
                
                let imageURL = NSURL(string: imageURLString)
                
                if let imageData = NSData(contentsOfURL: imageURL!) {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                    
                    
                    self.imageViewBookPicture.image = UIImage(data: imageData)
                        
                    }
                }
                
                
                
                
                
            }
            catch _ {
                
            }
            
            
        // let text = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
        
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

    func showError() {
    
        dispatch_async(dispatch_get_main_queue()) {
        
        let ac = UIAlertController(title: "No hubo respuesta del servidor", message: "Verifica tu conexion de internet", preferredStyle: .Alert)
            
            ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        
            self.presentViewController(ac, animated: true, completion: nil)
        
        }
    }

    func updateTitle(titleName: String) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.lblDisplayTitle.text = titleName
            
        })
    }

    
    
    
}

extension String {


    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersInString: matchCharacters).invertedSet
        return self.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
    }


    
    
}


