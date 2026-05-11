


import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ps_kiralama/services/supabase_client.dart';
// supabase_client.dart dosyasında nesnemi oluşturdum tekrar tekrar oluşturmamak için KOD KALİTESİ ÖNEMLİ




class AuthService{

  Future<void> kayitOl({ // parametre olarak named parameter yapısında veri alıyoruz kullanıcıdan

    required String email,
    required String sifre,
    required String ad,
    required String soyad,
    required String tel,
    required String rol,

}) async{

    final response = await supabase.auth.signUp( //signup supabase ile hazır gelen bir fonksiyon ve get/post işlemi yapıyor.
      password: sifre,
      email: email,
      data: {"rol":rol}, // kullanıcı rolünü metadata olarak saklıyoruz.
    );

    final userId= response.user?.id; //UUID yi çektik.

    if(userId==null) { // eğer yukarıda ki kodlar çalışıp auth.users tablosunda veri eklendiyse UUID kontrolü yapıyoruz.
      throw Exception("Kayıt Başarısız");
    }
    else{
      if(rol=="satici"){ //içteli iflerde ise kaydı alınan satırların satıcı veya müşteri olduğunu kontrol ediyoruz.

        await supabase.from("saticilar").insert({ // Burada ise saticilar tablosuna bilgi eklemesi yapılıyor.

          "user_id" : userId,
          // auth users'a giden userId Satıcılar tablosunda FK olarak bulunduğu için
          // satıcılar tablosunda otomatik olarak bir satici_id zaten oluşturuluyor.
          // Aynı zamanda satıcılarda enlem ve boylam bilgisi non null olmadığı için sonradan çağrılabilir.
          "satici_adi" : ad,
          "satici_soyadi" : soyad,
          "satici_teli" : tel,

        });
      }else if(rol=="musteri"){

        await supabase.from("musteriler").insert({

          "user_id" : userId,
          "musteri_adi" : ad,
          "musteri_soyadi" : soyad,
          "musteri_tel" : tel,

        });
      }
    }



    await supabase.from("logs").insert({

      "user_id" : userId, // buradaki user_id,islem,aciklama aslında LOGS tablosunun sütunlarıdır. o sütunlara karşılık olarak gelecek
      // veri burada belirleniyor. Log kaydı tutuluyor kısaca.
      "islem" : "Kayıt olundu",
      "aciklama" : "${email} adresiyle $rol olarak kayıt işlemi",

    });

}


Future<String> girisYap({
    required String email,
    required String sifre,
})async{
    final response = await supabase.auth.signInWithPassword( // şifreyle giriş yap yine supabase paketiyle geldi!
      email: email,
      password: sifre,
      // burada email şifre doğruysa UUID değerime ulaşabilirim demektir! UUID ye ulaştıktan sonra
      // eğer mail şifre yanlışsa hata fırlatır.
      //supabase mail doğrulaması yaptığı sırada ise user=null gelir işte bu yüzden aşağıda UUID == null kontrolü yapılır.
    );
    final userId= response.user?.id;
    if(userId==null) throw Exception("Giriş Başarısız - Mailinizi Onaylamayı Unutmayınız.");
    // eğer email doğrulaması sırasında giriş yapılırsa burada user null olduğu için hata fırlatır.

    //Eğer userId nullsa if den sonra aşağılar çalışmaz.
    // Eğer direkt mail şifre yanlış giriliyorsa hata fırlatır ve ondan sonra hiçbir kod satırı çalışmaz.
    // Boylelikle Log da gereksiz veri kaydedilmesi olmuyor.
    final rol = response.user?.userMetadata?["rol"] ?? "musteri";

    await supabase.from("logs").insert({

      "user_id": userId,
      "islem": "Giriş Yapıldı",
      "aciklama": "${email} adresiyle giriş yapıldı.",


    });

    return rol;

}

Future<void> cikisYap()async{

    final userId= supabase.auth.currentUser?.id;

    await supabase.from("logs").insert({

      "user_id" : userId,
      "islem" : "çıkış yapıldı",
      "aciklama" : "${userId} id'li kullanıcıdan çıkış yapıldı."

    });

    await supabase.auth.signOut(); // signOut dan sonrada log kaydı yapılamıyor sebebi çıkış yapınca veriler ulaşılamaz.
  // dolayısıyla çıkış yapmadan önce log kaydı aldık.


}

String? mevcutKullaniciRol(){ // uygulamayı kapattıktan sonra tekrar açınca oturumun açık kalıp kalmadığını kontrol etmek için yazdık.
    return supabase.auth.currentUser?.userMetadata?["rol"];
}


}

