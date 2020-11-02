//
//  ViewController.swift
//  Swift6GurunabiApp
//
//  Created by 山﨑隼汰 on 2020/10/31.
//

import UIKit
import MapKit
import Lottie


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DaneCatchDataProtocol {
    
    

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var animationview = AnimationView()
    
    let locotionManager = CLLocationManager()
    
    //apikeyを宣言する
    var apikey = ""
    
    var shopDataArray = [ShopData]()
    var totalHitCount = Int()
    var urlArray = [String]()
    var imageStringArray = [String]()
    var nameStringArray = [String]()
    var telArray = [String]()
    
    var annotation = MKPointAnnotation()
    
    //他のメソッドでも使用したいのでここで宣言する。緯度経度は基本的にDouble型で宣言される
    var idovalu = Double()
    var keidoValu = Double()
    
    var indexNumber = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startUpdatingLocation ()
        configureSubViews()
    }

//Lottieを表示するプログラム
    func startLoad(){
        
        animationview = AnimationView()
        let animation = Animation.named("1")
//aimationViewのフレームを決める
        //boundsはviewの全体という意味
        animationview.frame = view.bounds
        // Animation.named("1")を登録
        animationview.animation = animation
        //コンテントモード
        animationview.contentMode = .scaleAspectFit
        animationview.loopMode = .loop
        //アニメーションをプレイする
        animationview.play()
        //viewにセットする
        view.addSubview(animationview)
        
    }
    
    //位置情報を取得していいかの許可を出す //テンプレートがある
    func startUpdatingLocation() {
       
        locotionManager.requestWhenInUseAuthorization()
        
        let status = CLAccuracyAuthorization.fullAccuracy
        if status == .fullAccuracy{
            
            locotionManager.startUpdatingLocation()
            
        }
        
        
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .notDetermined, .denied, .restricted:
            
            break
        
        default: //未処理のケース
            print("Unhandled case")
            
            
        }
        switch manager.accuracyAuthorization {
        case .reducedAccuracy: break
        case .fullAccuracy: break
        
        default: //これは起こらない？
            print("This should not happen!")
        }
        
        
    }
    
    
    
    func configureSubViews() {
        
        locotionManager.delegate = self
        //どのくらいの範囲でお店を探すか
        locotionManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locotionManager.requestWhenInUseAuthorization()
        
        //どれだけが移動したら更新していくのか
        locotionManager.distanceFilter = 10
        //場所の更新をもう一度読んであげる
        locotionManager.startUpdatingLocation()
        
        
        mapView.delegate = self
        mapView.mapType = .standard
        //.followの部分を変えて動作確認する
        mapView.userTrackingMode = .follow
        
    }
    
    //緯度経度を取得する
    func locationManager(_ manager: CLLocationManager,didUpdeteLocations locations: [CLLocation]) {
         
        //一番最初にとれた地点をlocationに代入する
        let location = locations.first
        //緯度の取得
        let latitude = location?.coordinate.latitude
        //経度の取得
        let longitude = location?.coordinate.longitude
        
        //他のメソッド内で緯度経度の値を使いたいので、上記の宣言した箱に値を代入する
        idovalu = latitude!
        keidoValu = longitude!
    }
    
    
    @IBAction func search(_ sender: Any) {
  
    //textFieldを閉じる
        textField.resignFirstResponder()
        
    //ローディングを行なう
        startLoad()
    
    //検索する文字が入ったTextFieldの文字、didUpdateLactionsで入ってきた緯度k、経度とAPIKEYを用いて、URLを作成
        
        let urlStirng = ""
        
        //AnalyticsModelへ通信を行なう(値を渡す)
     let analyticsModel = AnalyticsModel(latitude: idovalu, longitude: keidoValu, url: urlStirng)
        
        analyticsModel.daneCatchDataProtocol = self
        
        analyticsModel.setData()
        
        
    }
    
    
    func addAnnotation(shopData:[ShopData]){
        
        removeArray()
        
        for i in 0...totalHitCount - 1 {
            
            print(i)
            annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(shopDataArray[i].Latitude!)!, CLLocationDegrees(shopDataArray[i].longitude!)!)
      
            //タイトル、サブタイトル
            annotation.title = shopData[i].name
            annotation.subtitle = shopData[i].tell
            urlArray.append(shopData[i].url!)
            imageStringArray.append(shopData[i].shopimage!)
            nameStringArray.append(shopData[i].tell!)
            mapView.addAnnotation(annotation)
            
            
        }
        
        //キーボードの画面を閉じる
        textField.resignFirstResponder()
            
        }
            
    func removeArray()  {
        
        //mapViewアノテーションを消去する→お店を検索するたびに消去する
        mapView.removeAnnotation(mapView.annotations as! MKAnnotation)
        
        //初期化をする 再度検索をかけると値を残るので、初期化する
        urlArray = []
        imageStringArray = []
        nameStringArray = []
        telArray = []
        
    }
    
    
    
    
    func catchData(arrayData: Array<ShopData>, resultCount: Int) {
        
        //arrayData,resultCount
        
        //ローディングアニメーションを閉じる
        animationview.removeFromSuperview()
        shopDataArray = arrayData
        totalHitCount = resultCount
        
        
        //shopDataArrayの中身を取り出して,ピン(annotation)を設置する
        addAnnotation(shopData: shopDataArray)
        
        
    }
    
    //アノテーションがタップされた時に呼ばれるデリゲートメソッド
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //情報をもとに、詳細ページへ画面繊維
        indexNumber = Int()
       
        //nameStringArrayの配列から何番目ですか？
        if nameStringArray.firstIndex(of: (view.annotation?.title)!!) != nil{
            
            indexNumber = nameStringArray.firstIndex(of: (view.annotation?.title)!!)!
            print(indexNumber)
            
            
        }
     
        performSegue(withIdentifier: "detailVC", sender: nil)
        
        
    }
 
    
    //画面遷移をしながら値を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailVC = segue.description as! DetailViewController
        detailVC.name = nameStringArray[indexNumber]
        detailVC.tel = telArray[indexNumber]
        detailVC.imageURLstring = imageStringArray[indexNumber]
        detailVC.url = urlArray[indexNumber]
        
    }
    
    
}

