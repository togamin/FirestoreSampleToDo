## 【swift4】Firestoreを利用した簡易ToDoアプリの作成

![FirestoreSample00](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/FirestoreSample00.jpg)

<h2>はじめに</h2>

Googleが提供する、Firebaseのデータベース「Firestore」を用いて、簡単なToDoアプリを作りました。

データベースへの操作の基本である、データの「作成：Create」「読み込み：Read」「更新：Update」「削除：Delete」といったCRUD処理の仕方について、簡単なToDoアプリの作成を例に説明していきます。

データベース「Firestore」に関する詳細は以下に記述しているので、この記事を読み進める前に、読んでください。

<a href = "https://togamin.com/2018/10/11/firebase01/">＞【Swift4】Firebaseのデータベース「Firestore」の解説</a>

<h2>作成するToDoアプリの概要</h2>

簡単なToDoアプリを作りました。ただ複数人で使った場合、他の人が登録したToDoも出てきてしまいます(笑)

データベースの基本操作を実装する事を目的にしてるので、細かい事は無視します(笑)

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Firestoreデータベースを使用したToDoアプリのサンプル <a href="https://t.co/NHBtw8Nlfs">pic.twitter.com/NHBtw8Nlfs</a></p>&mdash; とがみん@セブなう。本質を追求するブロガー (@togaminnnn) <a href="https://twitter.com/togaminnnn/status/1052582743014428672?ref_src=twsrc%5Etfw">2018年10月17日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<h2>Firebaseとプロジェクトの連携</h2>

アプリからFirebaseの「Firestoreデータベース」使うにあたって、それらを連携させる必要があります。

まずはその方法について説明します。

<h3>Firebaseにログイン</h3>

<a href = "https://firebase.google.com/?hl=ja">Firebaseのホームページ</a>に行き、ログインします。すると、以下のようなページに遷移するので、`プロジェクトを追加`を選択し、プロジェクトの登録を行います。

![Screen Shot 2018-10-17 at 10.04.26](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/Screen Shot 2018-10-17 at 10.04.26.png)

プロジェクト名を記入し、全てにチェックを入れ`プロジェクトを作成`を選択して完了です。

![Screen Shot 2018-10-17 at 10.15.54](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/Screen Shot 2018-10-17 at 10.15.54.png)

プロジェクトの作成が完了すると、以下のような画面に遷移します。

![FirestoreSampleToDo1](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/FirestoreSampleToDo1.jpg)

次に上図の`iOS`を選択します。すると、以下のような画面に遷移します。Xcodeで立ち上げた、プロジェクトのバンドルIDを入力し、`アプリを登録`を押します。

アプリのニックネームやApp Store IDは省略します。

![FirestoreSampleToDo2](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/FirestoreSampleToDo2.jpg)

次に以下のような画面に遷移するので、`GoogleService-Info.plist` ファイルをダウンロードし、Xcodeのプロジェクトに追加します。

![Screen Shot 2018-10-17 at 10.41.32](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/Screen Shot 2018-10-17 at 10.41.32.png)

ここで一つ気をつけないといけないことがあります。

過去に`GoogleService-Info.plist`をダウンロードしている場合、その名前が`GoogleService-Info (1).plist`というようにファイル名の右に数字がついてしまっていることがあります。

ファイル名が`GoogleService-Info.plist`でない場合、Xcodeで、そのファイルを読み込むことができず、エラーが出てしまうので、ファイル名を直す必要があります。

次に、CocoaPodsを利用して、FirebaseのFirestoreを使うにあたって必要なライブラリをインストールします。

<a href = "https://qiita.com/shishimo@github/items/d7f508e2489bcc68050e">＞CocoaPodsを使うための準備</a>

ターミナルを開き、作成したプロジェクトがあるフォルダまで移動し、`pod init`と入力し実行します。

すると、プロジェクトのフォルダ内に、`Podfile`というファイルがあるので、そこに以下の2行を追加します。

```swift
pod 'Firebase/Core'
pod 'Firebase/Firestore'
```

`Firebase/Core`はiOSアプリでFirebaseを稼働させるために必要なライブラリがインストールされます。

`Firebase/Firestore`はFirestoreを使うために必要なライブラリがインストールされます。

追加した後、保存し、再びターミナルに戻り、`pod install`と入力すると、ライブラリがインストールされます。

新しく白色のファイルが作成されているので、アプリの開発はそのファイルを使って行きます。

![FirestoreSampleToDo3](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/FirestoreSampleToDo3.jpg)

次に、白色のファイルを開き、`AppDelegate.swift`ファイルに、以下の2行を下の写真のように書きます。

```swift
import Firebase
FirebaseApp.configure()
```



![Screen Shot 2018-10-17 at 13.33.00](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/Screen Shot 2018-10-17 at 13.33.00.png)

`import Firebase`でFirebaseのフレームワークをSwiftで使えるようにし、`FirebaseApp.configure()`で、Firebaseの初期設定をします。

これで、Firebaseとアプリとの連携は完了です。

<h2>Firestoreを使う準備</h2>

Firebaseと連携が終わったので、次はデータベース「Firestore」を使う準備をします。Firebaseコンソールのメニューから`Database`を選択すると、以下のような画面になります。

データベースの作成を行います。アクセス権限に関するダイアログが出てくると思うのですが、後から変更できるので`テストモード`にチェックを入れ、始めます。

![Screen Shot 2018-10-17 at 15.55.02](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/Screen Shot 2018-10-17 at 15.55.02.png)

次に、Xcodeの作成したプロジェクトの`ViewController.swift`を開き以下のようにコードを記入します。

Firestoreを扱うための変数を宣言し、インスタンス化します。

```swift
//フレームワークを追加
import Firebase
import FirebaseFirestore

class ViewController: UIViewController {
    
    //Firestoreを扱うための変数を宣言。
    var db : Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Firestoreのインスタンス化
        db = Firestore.firestore()
        
    }
}
```

これでFirestoreを使う準備ができたので、次にデータベースへのデータの「作成：Create」「読み込み：Read」「更新：Update」「削除：Delete」といったCRUD処理について説明します。

<h2>CRUD処理</h2>

<h3>データの作成</h3>

以前の記事で述べたように、「Firestore」はドキュメント指向型のデータベースで、「コレクション」と「ドキュメント」、「データ」で構成されています。

以下のコードが、データを作成する時のコードで、`ToDoListコレクション`の中に`data`が入ったドキュメントを作成しています。

<a href = "https://togamin.com/2018/10/11/firebase01/">＞【Swift4】Firebaseのデータベース「Firestore」の解説</a>

```swift
func creatData(data:[String:Any]){
	db.collection("ToDoList").addDocument(data: data){ err in
		if let err = err {
      		print("Error writing document: \(err)")
       	} else {
         	print("Document successfully written!")
    	}
   	}
}
```

addDocumentはそれぞれのドキュメントに対して、ランダムなIDを生成します。ランダムなIDが生成されることによって、データが上書きされてしまうことを防ぎます。

同じIDを指定すると上書きされてしまいます。

自分でドキュメントのIDを指定したい場合は以下のように書き換えることもできます。

```swift
db.collection("ToDoList").document(id)(data: data){}
```

データをデータベースに入れた後のFirestoreの状態は以下のようになっています。

![Screen Shot 2018-10-17 at 23.36.45](/Users/togamiyuki/Desktop/IOSTeach/SwiftSummary/images/Screen Shot 2018-10-17 at 23.36.45.png)

<h3>データの読み込み</h3>

`getDocuments()`で`ToDoListコレクション`の中のドキュメントを全て取得しています。その後、for分を使って、全てのドキュメントのIDとデータを取得しています。

```swift
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
```

`todoList = []`と`idList = []`を最初に書いている理由について、

もし、それらの配列を空にしなかったら、前回取得したデータが蓄積されてしまい、同じデータがどんどん溜まってしまいます。

なので、それらの配列を空にしています。

データを取得ご、テーブルをリロードすることによって、テーブルViewにデータを表示します。

<h3>データの更新</h3>

以下のように書くことによって、ドキュメントのIDが`id`のデータを`data`に上書きすることができます。



```swift
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
```

<h3>データの削除</h3>

以下のように書くことによって、ドキュメントのIDが`id`のデータを削除することができます。

```swift
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
```

以上がFirestoreデータベースを使うにあたって基本的な処理です。

<h2>GitHub</h2>

作成したサンプルはGitHubにあげています。参考にしてください。

<a href = "https://github.com/togamin/FirestoreSampleToDo.git">https://github.com/togamin/FirestoreSampleToDo.git</a>







<h2>まとめ</h2>

Firebaseへの連携、Firestoreへのデータの処理について書いてきました。

紹介した簡易的なToDoアプリのコードはGitHubにあげているので、参考にしながら作ってみてください。

良い練習になると思います。



ToDo







<h2>実装手順詳細</h2>

* アプリ作成の概要

  * シュミレーターで確認
    * 追加：「ToDo記入」→「追加」→「読み込み」
    * 削除：「削除」→「読み込み」
    * 更新：「編集」→「読み込み」
  * どんな感じでデータが挿入されるかも確認しながら見せる。

* アプリ開発

  * Firestoreを使う準備まで

    * [Firebaseのホームページ](https://firebase.google.com/?hl=ja)に行く。

    * Firebaseでプロジェクトを作成。
    * iOSを選択。バンドルIDなどを記入。「GoogleService-Info」を追加。

    * NewFile作成[Firestore]

    * ```swift
      //ターミナル
      pod init
      
      //Podfileに記入
      //iOS アプリで Firebase を稼働させるために必要なライブラリ
      pod 'Firebase/Core'
      //Firestoreを使うためのライブラリ
      pod 'Firebase/Firestore'
      ```

    * 「AppDelegate.swift」に以下を記入

    * ```swift
      import Firebase
      import FirebaseFirestore
      
      //didFinishLaunchingWithOptionsの中
      //Firebaseとの接続。GoogleService-Infoの情報を読み込む処理。
      FirebaseApp.configure()
      ```

    * Firestoreのインスタンス化。UIViewController.swiftへ

    * ```swift
      import Firebase
      import FirebaseFirestore
      
      var defaultStore : Firestore!
      
      //Firebaseのインスタンス化
      defaultStore = Firestore.firestore()
      ```

  * UIの配置

    - TextField × 1、「creat」ボタン、「read」ボタン、TableView、TableViewCell
    - コードに紐ずけ。

  * extension でクラスを拡張。CRUD処理を書く。

    ```swift
    //Firestoreデータベースの処理の関する関数。
    extension ViewController{
        //データ追加
        func creatData(){}
        //データ読み込み
        func readData(){}
        //データ更新
        func update(){}
        //データ削除
        func delete(){}
    }
    ```

  * データを追加する関数を書く。

  * ```swift
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
    ```

  * creatボタンが押された時の処理を追加。

  * ```swift
    var data = ["todo":todoTextField.text!]
    creatData(data:data)
    ```

  * 実行して追加されるかどうかの確認。

  * 読み出した値を入れるための配列を宣言

     ```swift
     var todoList:[String] = []
     var idList:[String] = []
     ```

  * データの読み込み

  * ```swift
     //データ読み込み
     func readData(){
     //ToDoListの中のドキュメントを全て取得し、idとtodoを取得。取得後テーブルをリロード。
        db.collection("ToDoList").getDocuments() { (querySnapshot, err) in
        		if let err = err {
           		print("Error getting documents: \(err)")
        		} else {
        			for document in querySnapshot!.documents {
            		self.idList.append(document.documentID)
             	self.todoList.append(document.data()["ToDo"] as! String)
           		}
            		self.todoTableView.reloadData()
       		}
       	}
     }
     ```

  * readボタンが押された時の処理を追加。

  * ```swift
     readData()
     ```

  * テーブルに関するコード記入

  * ```swift
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
     }
     ```

  * 実行して読み込み確認。読み込んだデータがどんどん追加されていく。どうすれば解決できるか質問。読み込む前に、配列をからにする。

  * ```swift
     todoList = []
     idList = []
     ```

  * テーブルでせるをスライドさせた時に表示するボタンを作成

  * ```swift
     //セルを横にスライドさせた時に呼ばれる
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
       	//データの削除用ボタン
        	let deleteCell: UITableViewRowAction =     UITableViewRowAction(style: .normal, title: "削除"){ (action, index) -> Void in
        		//データの削除処理
        	}
     	deleteCell.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8)
        	return [deleteCell]
     }
     ```

  * データの削除

  * ```swift
     func delete(id:String){
     	db.collection("ToDoList").document(id).delete() { err in
       		if let err = err {
          		print("Error removing document: \(err)")
       		} else {
           		print("Document successfully removed!")
        		}
     	}
     }
     ```

  * セルを横にスライドして削除する部分に記述

  * ```swift
     delete(id:String)
     ```

  * セルをタップされた時の処理

  * ```swift
     //セルをタップした時に呼ばれる処理。
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     	//アラートの設定
        	let alert = UIAlertController(title: "データを編集します", message: nil, preferredStyle: .alert)
       	//OKボタン
        	alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction!) -> Void in
         	//OKを押した後の処理。
        	}))
       	//キャンセルボタン
       	alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: {(action:UIAlertAction!) -> Void in
        		//キャンセルを押した後の処理。
      	}))
         // テキストフィールドを追加。取り出し方は右「alert.textFields![0].text!」
      	alert.addTextField(configurationHandler: {(addTitleField: UITextField!) -> Void in
        		addTitleField.text = self.todoList[indexPath.row]
         	addTitleField.placeholder = "タイトルを入力してください。"//プレースホルダー
       	})
       	//その他アラートオプション
        	alert.view.layer.cornerRadius = 25 //角丸にする。
        	self.present(alert,animated: true,completion: {()->Void in print("アラート表示")})
     }
     ```

  * データ更新の関数を書く

  * ```swift
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
     ```

  * アラートをokした時に動作する場所に記入。

     ```swift
     var data = ["todo":alert.textFields![0].text]
     self.update(id:self.idList[indexPath.row],data: data)
     ```

  * 宿題もっと使いやすくしてくる。

     * アラート
     * 更新、削除、追加した後自動で読み込まれるようにする
     * キーボードを直す処理入れる

  * 

  * 

  * 

  * 



* 参考文献

  * [データベースを選択: Cloud Firestore または Realtime Database](https://firebase.google.com/docs/database/rtdb-vs-firestore?hl=ja)

  * [Firebase Realtime DBを実践投入するにあたって考えたこと](https://qiita.com/1amageek/items/64bf85ec2cf1613cf507)
  * [Cloud FirestoreのSubCollectionとQueryっていつ使うの問題](https://qiita.com/1amageek/items/d2ef7a49bccf5b4ea78e)
  * [Cloud Firestore データモデル](https://firebase.google.com/docs/firestore/data-model?hl=ja)
  * [ドキュメント指向データベースと列指向データベース](https://thinkit.co.jp/story/2010/10/15/1798)