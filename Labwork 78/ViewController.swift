//
//  ViewController.swift
//  Labwork 78
//
//  Created by Алихан Пешхоев on 17/01/2019.
//  Copyright © 2019 Алихан Пешхоев. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var results:[[String:Any]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tableView.dataSource = self
        tableView.delegate = self
        searchTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSearch()
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "resultCell") as! ResultTableViewCell
        
        let title = results[indexPath.row]["title"] as! String
        var authorsString = ""
        
        if (results[indexPath.row]["authors"] == nil) {
            authorsString = "(нет автора)"
        } else {
            let authorsList = results[indexPath.row]["authors"] as! [String]
            if authorsList.count == 1 {
                authorsString = authorsList[0]
            } else {
                var i = 0
                for item in authorsList {
                    if i == authorsList.count-1 {
                        authorsString += " " + item
                    } else {
                        authorsString += item + ","
                    }
                    
                    i=i+1
                }
                
            }
        }
        
        
        cell.authorLabel?.text = authorsString
        cell.titleLabel?.text = title

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    @IBAction func searchButtonAction(_ sender: Any) {

        performSearch()
        
    }
    
    func performSearch() {
        activityIndicator.startAnimating()
        let searchText = searchTextField.text?.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(searchText ?? "")&maxResults=40".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlString!)
        let session = URLSession.shared
        if let usableUrl = url {
            let task = session.dataTask(with: usableUrl, completionHandler: { (data, response, error) in
                if let data = data {
                    if let stringData = String(data: data, encoding: String.Encoding.utf8) {
                        
                        let resObject = self.convertToDictionary(text: stringData)
                        
                        self.results = []
                        if (resObject!["items"] != nil) {
                            for item in resObject!["items"] as! [[String:Any]]{
                                self.results.append(item["volumeInfo"] as! [String:Any])
                            }
                        }
                    }
                } else {
                    let alertController = UIAlertController(title: "Ошибка", message: "При получении данных произошла ошибка. Проверьте подключение к интернету.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action: UIAlertAction!) in
                        alertController.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            })
            task.resume()
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


