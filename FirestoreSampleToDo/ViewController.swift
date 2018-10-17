//
//  ViewController.swift
//  FirestoreSampleToDo
//
//  Created by Togami Yuki on 2018/10/17.
//  Copyright © 2018 Togami Yuki. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


class ViewController: UIViewController {

    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var todoTableView: UITableView!
    
    //Firestoreを扱うための変数を宣言。
    var db : Firestore!
    
    //Firestoreから読み出した値を入れるための変数を宣言。
    var todoList:[String] = []
    var idList:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todoTableView.delegate = self
        todoTableView.dataSource = self
        
        //Firestoreのインスタンス化
        db = Firestore.firestore()
        //Firestoreからデータの呼び出し
        readData()
        //キーボードをしまうボタン追加
        keyboad()
        
    }
    
    //Firestoreへのデータの追加
    @IBAction func create(_ sender: UIButton) {
        var data = ["todo":todoTextField.text!]
        creatData(data:data)
    }
    
    //Firestoreからのデータの読み込み
    @IBAction func read(_ sender: UIButton) {
        readData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
}

//Firestoreデータベースの処理の関する関数。
extension ViewController{
    //データ追加
    func creatData(data:[String:Any]){
        db.collection("ToDoList").addDocument(data: data){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    //データ読み込み
    func readData(){
        todoList = []
        idList = []
        //ToDoListの中のドキュメントを全て取得し、idとtodoを取得。取得後テーブルをリロード。
        db.collection("ToDoList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.idList.append(document.documentID)
                    self.todoList.append(document.data()["todo"] as! String)
                }
                self.todoTableView.reloadData()
            }
        }
    }
    //データ更新
    func update(id:String,data:[String:Any]){
        db.collection("ToDoList").document(id).setData(data){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    //データ削除
    func delete(id:String){
        db.collection("ToDoList").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}




//テーブルに関する関数。
extension ViewController: UITableViewDelegate,UITableViewDataSource{
    
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idList.count
    }
    
    //セルのインスタンス化
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = todoList[indexPath.row]
        
        return cell
    }
    //セルを横にスライドさせた時に呼ばれる
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //データの削除用ボタン
        let deleteCell: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除"){ (action, index) -> Void in
            //データの削除処理
            self.delete(id:self.idList[indexPath.row])
        }
        deleteCell.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)
        return [deleteCell]
    }
    //セルをタップした時に呼ばれる処理。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //アラートの設定
        let alert = UIAlertController(title: "データを編集します", message: nil, preferredStyle: .alert)
        //OKボタン
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction!) -> Void in
            //OKを押した後の処理。
            var data = ["todo":alert.textFields![0].text]
            self.update(id:self.idList[indexPath.row],data: data)
        }))
        //キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: {(action:UIAlertAction!) -> Void in
            //キャンセルを押した後の処理。
        }))
        // テキストフィールドを追加。
        alert.addTextField(configurationHandler: {(addTitleField: UITextField!) -> Void in
            addTitleField.text = self.todoList[indexPath.row]
            addTitleField.placeholder = "タイトルを入力してください。"//プレースホルダー
        })
        //その他アラートオプション
        alert.view.layer.cornerRadius = 25 //角丸にする。
        self.present(alert,animated: true,completion: {()->Void in print("アラート表示")})
    }
}

//キーボード追加
extension ViewController{
    func keyboad(){
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action:#selector(self.closeKeybord(_:)))
        kbToolBar.items = [spacer, commitButton]
        todoTextField.inputAccessoryView = kbToolBar
    }
    @objc func closeKeybord(_ sender:Any){
        self.view.endEditing(true)
    }
}






