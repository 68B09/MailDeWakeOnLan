#!/usr/bin/ruby

# メールでwakeonlan
# メール本文の１行目に合い言葉、２行目にMACアドレス(:もしくは-区切り)を書いて送る
# (ex)
# hogehoge
# 00:00:5E:00:53:FF
#
# COPYRIGHT (C) 2020 ZZO@MB68C09
#
# V1.0 2020.4.11

require 'net/pop'

# 環境設定

# 合い言葉
magicnumber = 'hogehoge'
# wakeonlanコマンドのパス
wakeonlancmd = '/usr/bin/wakeonlan'
# pop3サーバアドレス
pop3svr = "pop3.example.jp"
# pop3サーバポート
pop3port = 110
# wakeonlan受付メールアカウントID
pop3id = 'example@example.jp'
# wakeonlan受付メールアカウントパスワード
pop3pw = 'example'

# 環境設定ここまで

# ここから下は弄らない
puts 'enter ' + Time.new.to_s()

# wakeonlanコマンド存在チェック
if File.exist?(wakeonlancmd) == false then
	printf("%s not found\n", wakeonlancmd);
	exit!
end

macadrregex = Regexp.new("^[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]$", Regexp::IGNORECASE)

# メール受信とwakeonlan実行
begin
	Net::POP3.start( pop3svr, pop3port, pop3id, pop3pw ){ |pop|
		if pop.mails.empty? then
			puts 'empty'
		else
			puts "#{pop.mails.size} mails"
			mailno = 1
			pop.each_mail do |m|
				printf("recv mail %d ", mailno)

				from = ""
				magic = ""
				mac = ""
				isBody = false
				m.pop do |line|
					linewk = line.chomp

					if linewk.empty? then
						isBody = true
						next
					end

					if isBody == false then
						if linewk.index('From:') == 0 then
							from = linewk
							puts from
						end
						next
					end

					if magic.empty? then
						magic = linewk
					elsif mac.empty? then
						# '-'→':'
						linewk = linewk.gsub('-', ':')
						if macadrregex.match(linewk) then
							mac = linewk
							#break #ココでbreakしたいけどbreakするとエラーになる
						end
					end
				end

				# 合い言葉が一致していればwakeonlanコマンドを実行
				if magic == magicnumber then
					if mac.empty? == false then
						puts 'mac:' + mac
						ret = system(wakeonlancmd + ' ' + mac)
						retmsg = ret.to_s();
						if ret == nil then
							retmsg = "nil";
						end
						puts 'wakeonlan result:' + retmsg
					end
				else
					puts 'magicnumber mismatch'
				end

#				m.delete()

				mailno = mailno + 1
			end
		end
	}
rescue => error
	puts 'rescue'
	puts error
end

# 処理出来ずに受信BOXが溢れないように。
# 処理エラーになるメールより後に届いたメールが処理されないことを防ぐため。
# 全メールを削除。
# 運悪くこのタイミングで届いたメールは消されるが再送信に期待する。
Net::POP3.delete_all(pop3svr, pop3port, pop3id, pop3pw, false)
