//
//  ViewController.swift
//  Birja
//
//  Created by Рамиль Алиев on 31.01.2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var compnamelabel: UILabel!
    @IBOutlet weak var companypickerview: UIPickerView!
    @IBOutlet weak var activityind: UIActivityIndicatorView!
    @IBOutlet weak var compnamesymbol: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var changelabel: UILabel!
    private lazy var companies = [
        "Apple": "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Amazon": "AMZN",
        "Facebook": "FB"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        compnamelabel.text = "Tinkoff"
        // Do any additional setup after loading the view.
        companypickerview.dataSource = self
        companypickerview.delegate = self
        activityind.hidesWhenStopped = true
        activityind.startAnimating()
        requestQuoteUpdate()
        
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(companies.keys)[row]
    }
    private func requestQuoteUpdate(){
        activityind.startAnimating()
        compnamelabel.text = "-"
        compnamesymbol.text = "="
        label.text = "-"
        changelabel.text = "-"

        let selectedRow = companypickerview.selectedRow(inComponent: 0)
        let selectedSymbol = Array(companies.values)[selectedRow]
        requestQuote(for: selectedSymbol)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activityind.startAnimating()
        let selectedSymbol = Array(companies.values)[row]
        requestQuote(for: selectedSymbol)
    }
    private func requestQuote(for symbol: String){
        let token = "pk_4335b7641e304f6e89cfe43a99cb4"
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)")else{
            return
        }
        let dataTask = URLSession.shared.dataTask(with: url){ [weak self] (data,response,error) in
            if let data = data,
               (response as? HTTPURLResponse)?.statusCode == 200,
               error == nil{
                self?.parseQuote(from: data)
            }else{
                print("Network error!")
            }
        }
        dataTask.resume()
    }
    private func parseQuote(from data: Data){
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double else { return print("Invalid JSON")}
            DispatchQueue.main.async{[weak self] in self?.displayStockInfo(companyName: companyName, companySymbol: companySymbol, price: price, priceChange: priceChange)
            }
        }catch{
            print("JSON parsing error: " + error.localizedDescription)
        }
    }
    private func displayStockInfo(companyName: String, companySymbol: String, price: Double, priceChange: Double){
        activityind.stopAnimating()
        compnamelabel.text=companyName
        compnamesymbol.text=companySymbol
        label.text = "\(price)"
        changelabel.text = "\(priceChange)"
    }
}

