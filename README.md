# maildewol.rb  
メールでWakeOnLan
======================

なにするもの？
------
メールとWakeOnLanを利用してPCを起動するためのrubyスクリプトです。  
指定のメールアドレス宛にメールが届いたら、メールに書かれているMACアドレス宛てにWakeOnLanパケットを送信します。  

用途
------
・テレワークなどで自宅から社内PCの電源をONにしたい  
・外出先から自宅PCの電源をONにしたい  

条件
------
１、WakeOnLanというものをご存じであること  
２、外部から起動させたい社内PC(クライアントPCと呼ぶ)がWakeOnLan対応で、かつ、WakeOnLanで起動できる状態に設定できていること  
　　(注意)無線LANではWakeOnLanはできません  
３、社内に、常時稼動可能でlinuxがインストールできる機器(サーバPCと呼ぶ)があること(既存サーバを使うのはオススメしない)  
４、サーバと起動したいPCが同一LAN内に存在すること(サーバPCからのブロードキャストパケットがクライアントPCに届くこと)  
５、linuxやrubyなどのインストールや、cronの設定などが出来る程度のlinuxの知識があること  
６、rubyおよびwakeonlanコマンドが必要です  
７、POP3で利用可能な専用のメールアドレスが必要です  
８、事前に情シスに相談すること  
９、自分で全責任が取れること  

検証は初代Raspberry Pi model Bで行いました。  
検証に使用したOSは2020-02-13-raspbian-buster.zip。  

環境構築手順
------
まずはクライアントPCは１台のみ試すこと。  
上手くいったら他のクライアントPCも設定する。  

１、【クライアントPC】  
１－１、起動したいクライアントPCがWakeOnLanで起動できるようにする  
設定方法はネットを探せば出てきます。  
WakeOnLanに対応していないPCも多々あります。  
必ずWakeOnLanで起動できることを確認してから次の手順に進む。  
起動確認の為に使用するWindows用のWakeOnLanパケット送信ツールは探せば多々見つかります。  
(WOL Controller スタンダード版など)  

１－２、クライアントPCのMACアドレスを調べる  
調べかたはネットで調べると沢山出てきます。  
Windowsならコマンドプロンプトで ipconfig /all など。  

(注意)このMACアドレスは、このPCを起動させたい人が自宅からメールを送るときに必ず入力する必要があります  
メモして帰るか、プライベートメールに送信するなどして忘れないよう要請しておきましょう。  

２、【情シスにお願いする】  
２－１、専用のメールアドレスを確保する  
POP3で受信可能なメールアドレスを作る。もしくは作って貰う。  
(注意)本スクリプトは受信したメールを削除するので、絶対に新規に作成したメールアドレスを使うこと。  

３、【サーバPC】  
３－１、サーバPCにlinuxをインストール  
※動作確認で使用したのは初代raspberry pi model B  
※raspberry piなら安く作れると思う  

３－２、rubyをインストール  
(例)sudo apt-get install ruby  
※動作確認したのはruby 2.5.5p157 (2019-03-15 revision 67260) [arm-linux-gnueabihf]  

３－３、wakeonlanをインストール  
(例)sudo apt-get install wakeonlan  

インストールしたら試しにクライアントPCをWakeOnLanで起動してみる。  
(例)wakeonlan MACアドレス  

もちろんクライアントPCの電源は事前にOFFであること。  

３－４、このページからダウンロードした maildewol.rb を /usr/local/bin に配置する  
rootがmaildewol.rbを実行できるように、chmod 755とでもしておく。  

３－５、maildewol.rbをエディタで開いて下記項目を設定して保存する  
・magicnumber…合い言葉。なんでもいい。英数大小文字と数字の組み合わせで、出来れば10文字以上で定義する。  
・wakeonlancmd…wakeonlanコマンドをフルパスで。通常は初期値であっているはず。  
・pop3svr…「２－１」で作ったメールを受信するためのPOP3サーバ名。  
・pop3port…同ポート番号。通常は初期値であっているはず。  
・pop3id…同メールを受信するときのID。  
・pop3pw…同メールを受信するときのパスワード。  

(注意)magicnumberは、このPCを起動させたい人が自宅からメールを送るときに必ず入力する必要があります  
メモして帰るか、プライベートメールに送信するなどして忘れないよう要請しておきましょう。  

４、【初期動作確認】  
４－１、サーバPCで maildewol.rb を実行する  
下記のメッセージが表示されたならOK。  
※日時は異なる  
*****  
enter 2020-04-11 15:00:33 +0900  
empty  
*****  
「rescue」が表示されたなら設定が間違っているので見直す。  

４－２、対象のクライアントPCの電源をOFFにする  

４－３、PCからでもスマホからでも良いから次の内容の起動リクエストメールを送信する  
・送信先…「２－１」で作ったアドレス  
・件名…何か適当に。「おはよう」でもOK。  
・本文…1行目に合い言葉、2行目にクライアントPCのMACアドレス  
(例)  
hogehoge  
00:00:5E:00:53:FF  

４－４、サーバPCで maildewol.rb を実行する  
下記のメッセージが表示され、かつ、クライアントPCが起動したならOK。  
※日時やメールアドレス、MACアドレスは異なる  
*****  
enter 2020-04-11 11:56:04 +0900  
1 mails  
recv mail 1 From: 送信元メールアドレス  
mac:00:00:5E:00:53:FF  
Sending magic packet to 255.255.255.255:9 with 00:00:5E:00:53:FF  
wakeonlan result:true  
*****  

メールサーバが忙しいときは届くのに時間がかかるため、「empty」が表示された場合はほどよく待ってから何度か試す。  

４－５、crontabに下記の１行を追加する  
*/2 * * * * root /usr/local/bin/maildewol.rb 1>> /var/log/maildewol.log 2>> /var/log/maildewol.log  

「*/2」は「２分間隔で」の意。  
利用者数とメールサーバの容量から最適な時間を設定して下さい。  
大きな値、例えば５分などにすると利用者が５分待たされかねないことに注意して下さい。  

５、【最終確認】  
５－１、サーバPCを再起動する  
サーバーPCは電源ONするだけで良いことを確認するため、再起動後にさわらないこと。  

５－２、クライアントPCを落としてから例の起動リクエストメールを送信する  
起動したならOK。  

その他、稼働時の注意など
------
・ログが溢れないように気をつけましょう  
ログは /usr/local/bin/maildewol.rb です。  

・リクエスト元メールアドレスがログに記録されるのでログの扱いには注意しましょう  
送信者は会社のメールアドレスが使用できないならgmail等で作った一時的なアドレスを使って送信するとか。  

・ASCIIの範囲が解釈できるならメールのエンコードは問わないと思われます  
ただしFromアドレスに漢字などが入っているとログに正しく記録できないと思います。  

・「自宅から起動できませんでした」は最悪なので、「クライアントPCが目の前にあるときに起動できることを確認する」ことを怠らないようにしましょう  
手持ちのスマホやガラケーで起動リクエストメールを送るなど。  

・メールアドレスと合い言葉がパスワードのようなものです  
合い言葉は長く、そして部外者に知られないようにしましょう。  
また、「メールアドレス」「合い言葉」「MACアドレス」はメールを送るときに必ず必要です。  
「わからなくなったからと他の人に聞いてもわからない」ことを周知徹底しましょう。  
管理者が常に出勤していれば助かりますが。   

・タイミングが悪くリクエストが受け付けられないときがあります  
利用者には「起動しない場合は○分置きにメールを送ってみて下さい」と伝えておきましょう。  

履歴
-----
1.0 2020.4.11 ZZO@MB68C09
