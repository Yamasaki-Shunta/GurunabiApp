//
//  AnalyticsModel.swift
//  Swift6GurunabiApp
//
//  Created by 山﨑隼汰 on 2020/11/01.
//

import Foundation
import Alamofire
import SwiftyJSON


protocol DaneCatchDataProtocol {
    
    //規則を決める
    func catchData(arrayData:Array<ShopData>,resultCount:Int)
    
}
//init(内部からで使うもの:外部から取得するもの){外部から取得するもの =　内部で使うもの}

class AnalyticsModel{
    
    //外部から渡ってくる緯度、経度
    var idoValue:Double?
    var keidoValue:Double?
    
    //APIKEY
    var urlStirng:String?
    
    //ShopData(構造体)を使用する箱を宣言する
    var shopDataArray = [ShopData]()
    //DaneCatchDataProtocolをインスタンス化)(他のクラスでも使える)
    var daneCatchDataProtocol: DaneCatchDataProtocol?
    
    //ViewControllerから値を受け取る //ここ重要！！
    init(latitude:Double,longitude:Double,url:String) {
        
        idoValue = latitude
        keidoValue = longitude
        urlStirng = url
    }
    
    //JSON解析を行なう
    func setData() {
        
    let encordeUrlStirng:String = (urlStirng!.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed))!
    
    //Alamofireを用いる
        AF.request( encordeUrlStirng, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            
            //値がちゃんと入ってきているかを確認する
            print(response.debugDescription)
            
            switch response.result{
            
            
            case .success:
                do{
                    let json:JSON = try JSON(data: response.data!)
                   
                    print(json.debugDescription)
                    //APYKEYで取得できる項目"total_hit_count"
                    var totalHitCount = json["total_hit_count"].int
                    if totalHitCount! > 50 {
                        
                        totalHitCount = 50
                        
                        
                    }
                    //50回解析を行なう
                    for i in 0...totalHitCount! - 1 {
                        
                        if json["rest"][i]["latitude"] != "" && json["rest"][i]["longitude"] != "" && json["rest"][i]["url"] != "" && json["rest"][i]["name"] != "" && json["rest"][i]["tell"] != "" &&  json["rest"][i]["image_url"]["shop_image1"] != ""{
                        
                            let shopData = ShopData(Latitude:json["rest"][i]["latitude"].string,longitude: json["rest"][i]["longitude"].string, url: json["rest"][i]["url"].string, name: json["rest"][i]["name"].string, tell: json["rest"][i]["tell"].string, shopimage: json["rest"][]["image_url"]["shop_image1"].string)
                     
                            self.shopDataArray.append(shopData)
                            print(self.shopDataArray.debugDescription)
                            
                            
                        }else{
                            
                            print("何かしらが空です")
                            
                            
                        }
                    
                    
                }
                    
                    //catchDataはcatchDataのfunction　　　　//渡したい値
                    self.daneCatchDataProtocol?.catchData(arrayData: self.shopDataArray, resultCount: self.shopDataArray.count)
                    
                    
                    
                
                //エラーが見つかった表示する
                }catch{
                    
                    print("エラーです")
                    
        }
        break
            case.failure:break
            
    }
     
            
            
            
    }
    }
}
