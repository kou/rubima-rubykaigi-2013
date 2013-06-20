= ライブラリ開発者になろう

この記事は((<RubyKaigi 2013|URL:http://rubykaigi.org/2013>))の3日目の午後にあった((<Be a library developer!|URL:http://rubykaigi.org/2013/talk/S94>))という発表に関する記事です。発表のまとめと、発表に対するコメントにコメントします。

[Be a library developer!](slide-title.png) http://slide.rabbit-shocker.org/authors/kou/rubykaigi-2013/ へのリンクにしたい

発表資料は以下にあります。どれも同じPDFをアップロードしているので見やすいサイトで閲覧してください。

  * ((<SlideShare|URL:slideshare.net/kou/rubykaigi-2013>))
  * ((<Speaker Deck|URL:http://speakerdeck.com/u/kou/p/be-a-library-developer>))
  * ((<Rabbit Slide Show|URL:http://slide.rabbit-shocker.org/authors/kou/rubykaigi-2013/>))

当日の動画は以下にあります。どちらも同じ動画です。

  * ((<Ustream|URL:http://www.ustream.tv/recorded/33615831>))
  * ((<Vimeo|URL:https://vimeo.com/TODO>))

== 概要



このセッションでは、みなさんにライブラリー開発者になって欲しいなぁ、という話をします。私自身、いろいろなライブラリーを開発してきましたが、ライブラリーを開発することで得られたことがたくさんあったなぁと思います。それはみなさんにとっても役に立つことだと思います。これから話すことは私がライブラリーを開発してきて得られたことのエッセンスです。

== 概要

大まかにいうとこのような順に話します。

まず、1つ例をだしながら今回の話のゴールを説明します。聴いているみなさんと私が設定したゴールを共有できたならここでの話は成功です。

次に、共有したゴールを実現するためにキーとなる考えを説明します。これは、私がいろいろなライブラリーを開発している中で得られた考えです。

その後、いくつかの例に対してキーとなる考えを適用していきます。ここで、キーとなる考えで何をしようとしているかを聴いているみなさんがピンときたら成功です。

これで一通り説明が済んだのでおさらいします。聴いているみなさんが再確認できればいいなぁと思います。

最後に、ライブラリー開発者になった後のことについて少しだけ匂わしておしまいです。

== ゴール

それでは、例を出しながら今日の話のゴールを説明します。

まず、今日の話のゴールです。ゴールは「よりよいソフトウェアを開発するための方法をみなさんが知ること」です。このゴールを私と共有できそうですか？私はそのゴールを達成するためにこれから簡単な例をだしながら説明します。みなさんはこの方法は本当によりよいソフトウェアを開発する方法だろうかと自分の経験も踏まえながら考えてください。よりよいソフトウェアとはどんなソフトウェアか、それを開発するにはどうしたらよいかを考えるきっかけになるとうれしいです。

それでは、まずはよりよいソフトウェアとはどんなソフトウェアかを例を見ながら考えてみましょう。どうやって開発するかは、よりよいソフトウェアはどんなソフトウェアかを考えてからです。

こんなAPIがあります。これはrcairoというライブラリーのAPIです。rcairoはcairoというグラフィックスライブラリーのRubyバインディングです。

  # source: ruby
  context.save
  context.circle(50, 50, 10)
  context.stroke
  context.restore

saveで現在の描画情報を保存しておいてrestoreでsaveした状態まで戻します。描画情報とはどのように線を書くかとか、線の太さはどのくらいとか、そういうやつです。間にあるcircleとstrokeで円を書いています。

では、これをよりよくするためにはどうしたらよいでしょうか。「よりよい」の基準は人それぞれですが、まずは自分の「よりよい」の基準で考えてみてください。「よりよい」の指針のひとつは後で説明します。

saveとrestoreに注目してみるとどうでしょうか。

ここに注目するとブロックを使った書き方を思いつきます。こちらの方がよりよいAPIです。

  # source: ruby
  context.save do
    context.circle(50, 50, 10)
    context.stroke
  end

では、どうしてブロックを使ったほうがよりよいAPIなのでしょうか？それは、よりRubyらしい書き方だからです。「Rubyらしい」とはどういうことでしょうか？「○○らしい」とは「他と似ている」ということです。「Rubyらしい」書き方だとまわりのコードと似たような記述になります。つまり、まわりのコードと統一感が出るということです。統一感がでると読みやすくなります。読みやすくなるとメンテナンスが楽になるため開発を継続するためにはよりよいことです。よって、「Rubyらしい書き方」がよりよい基準のひとつです。

では、このブロックの使い方は「Rubyらしい」のでしょうか。Fileクラスを思い出してください。

  # source: ruby
  file = File.open(path) # 前処理
  file.read
  file.close             # 後処理

Fileクラスではopenでファイルを開きます。これは前処理です。readして使い終わったら閉じています。これは後処理です。

ただ、このように明示的にcloseを書くのはRuby初心者です。Rubyに慣れた人はこのようにブロックを使って書きます。

  # source: ruby
  File.open(path) do |file| # 前処理
    file.read
  end                       # 後処理

こうすることの利点は2つです。1つはcloseのし忘れがなくなるということです。もう1つは具体的にどう後処理をしなければいけないかを意識しなくてもよくなるということです。ファイルの場合の後処理はcloseで、Dir.chdirのときは元のディレクトリーに戻る、などと使いわける必要はありません。ブロックを抜けたら「いい感じ」に後処理をしてくれます。これが、Rubyの組み込みライブラリーで使われている後処理のためにブロックを使う方法です。つまり、これと「似た」使い方をすれば「Rubyらしい」ということです。

では、もう一度rcairoの例を見てみましょう。

  # source: ruby
  context.save do # 前処理
    context.circle(50, 50, 10)
    context.stroke
  end             # 後処理

saveが前処理の部分、ブロックを抜けたところで実行するrestoreは後処理の部分です。Fileと「似た」使い方ですね。ということで「Rubyらしい」といえます。

おさらいします。「よりよい」の基準の1つは「Rubyらしい」ということです。いいかえると「他と似ている」ということです。今日の話のゴールを覚えていますか？「よりよいソフトウェアを開発するための方法をみなさんが知ること」です。いいかえると、「似ているとはどういうことかを知って、それと同じようにすること」です。

私が設定したゴールを共有できましたか？共有できていれば、ここまでの話は成功です。

== キーとなる考え

次は、このゴールを実現するためのキーとなる考えを説明します。

キーとなる考えは、「想像するんじゃなくて思い出す」です。

「想像すること」は難しいことです。これはまだ知らないことだからです。

では、「思い出すこと」はどうでしょうか？これは、簡単なことです。すでに知っていることですから。ただし、知っていても忘れてしまうと思い出せません。

では、思い出せるようにするにはどうしたらよいかというと、知ることです。知るためには自分で経験する方法、人から聞く方法、観察して学ぶ方法などがあります。この中でも一番初めにやることは経験してみることです。経験すれば知っているので思い出せるようになります。

ということで、キーとなる考えは「想像するんじゃなくて思い出す」です。

== キーとなる考えを適用する

では、このキーとなる考えを適用してみましょう。

まず、このキーとなる考えで実現したいゴールの再確認です。ゴールは「よりよいソフトウェアを開発するための方法をみなさんが知ること」でしたね。

では、このゴールを実現するために何を経験すればいいでしょうか。それは、「Rubyユーザー」としての経験です。これは、すでにみなさん経験していますよね！

では、実際にその経験を活かしてみましょう。

  # source: ruby
  window.get_property("opacity")
  # よりよいAPIは？？？

これは、Ruby/GTK2というライブラリーのAPIです。Ruby/GTK+はGTK+というGUIツールキットのRubyバインディングです。

windowオブジェクトのopacityプロパティを取得しています。opacityとは透明度ですね。では、これをどうすればよりよいAPIになるか考えてみてください。よりよりAPIとはRubyらしいAPIでしたね。どうすればよりRubyらしいAPIになるでしょうか。

（15秒くらい待つ。）

  # source: ruby
  window.get_property("opacity")
  window.opacity # よりよいAPI

よりよいAPIとしてopacityというメソッドを提供しています。オブジェクトのプロパティを取得するためにプロパティ名のメソッドを使うというのはRubyではよくやる方法なのでRubyらしいです。プロパティを属性といいかえるとわかりやすいかもしれません。Rubyにはattr_readerというそのためのショートカットも用意されています。

ところで、みなさんは、今、よりよいAPIを考えられましたか？「思い出す」って「難しいじゃん」って思いませんでしたか？そう、難しいんです。「思い出せ！？」「Rubyらしいって何！？」そう思ったことでしょう。

すでに知っているはずなのにどうして思い出すことが難しいのでしょう。それは、「想像するんじゃなくて思い出す」という経験をしていないからです。今、みなさんは経験したのではなく、「聞いただけ」という状態です。

それでは、もう一度。ゴールを実現するためには何を経験したらよいのでしょうか。それは、ライブラリー開発者としての経験です。ここでようやくこの話のタイトルがでてきました。

ライブラリー開発者はRubyユーザーとして使いやすいAPIとはどういうAPIだろうと考えたり、ライブラリーのユーザーとしてわかりやすいドキュメントはどんなドキュメントだろう、ということを考えます。他にもいろいろ考えます。そして、これらを何度も何度もたくさん考えます。考える機会がたくさんあるのです。「たくさん」というのはとてもよい練習になります。そのため、「想像するんじゃなくて思い出す」をうまくやるためにはライブラリー開発者になることをオススメします。

それでは、APIとドキュメントの例を考えてみましょう。まずはAPIです。プロパティの値を取得するには以下のようにプロパティ名と同じメソッドを用意するのがRubyらしいのでしたね。

  # source: ruby
  # 低レベルなAPI
  window.get_property("opacity")
  # よりよいAPI
  window.opacity

それでは、visibleというプロパティという場合はどうでしょう。ヒントはvisibleは真偽値を返すということです。

  # source: ruby
  # 例レベルなAPI
  window.get_property("visible")
  # よりよいAPIは？
  # ???: ヒント: "visible"は真偽値を返す


（15秒くらい待つ）

Rubyらしくするならメソッド名の最後に「?」をつけますね。

  # source: ruby
  # 例レベルなAPI
  window.get_property("visible")
  # よりよいAPI
  window.visible?

では、なんでもメソッド名にすればよいのでしょうか？この例ではどうでしょう。

  # source: ruby
  # レコードを「コレクション」と考えるならよりよいAPI
  record["name"]
  # レコードを「オブジェクト」と考えるならよりよいAPI
  record.name

ここのrecordはテーブルの中の1つのレコードです。このレコードのカラムの値にアクセスするにはHashのようにアクセスするのとメソッドでアクセスするのはどっちがよいでしょうか？レコードをコレクションと考えるならHashのようにアクセスするのがRubyらしいですし、オブジェクトと考えるならメソッドでアクセスするのがRubyらしいですね。

ドキュメントについても考えてみましょう。

  インストール方法：

    Debian GNU/Linuxでは：
      % sudo apt-get install libgtk2.0-dev
      % gem install gtk2
    OS Xでは：
      ...

Ruby/GTK2は拡張ライブラリーなので事前にGTK+というCのライブラリーをインストールしておく必要があります。ユーザーのことを考えるとドキュメントにはその旨を書いておかないと、となります。でも、これでよいのでしょうか？よりよいドキュメントならこうするべきです。

  インストール方法：
    % gem install gtk2

gemをインストールするときは「gem install gem名」が普通のやり方です。これがRubyGemsらしさです。普通はこれでインストールするなら、これでインストールできるようにするべきなのです。Ruby/GTK2はgem install gtk2とやったら必要なパッケージを自動でインストールするようにして、インストールドキュメントはgem install gtk2だけにしています。

ということで、実際に「想像するんじゃなくて思い出す」というキーとなる考えを適用してみました。Rubyユーザーとして普通はどうやっているかを「思い出す」、そしてそれと同じようにする、という例を示しました。ピンときましたか？

== まとめ

まとめます。この話のゴールは「よりよいソフトウェアを開発するための方法をみなさんが知ること」でした。「よりよい」とは「Rubyらしい」、言い換えると「他と似ている」ということです。これを実現するためのキーとなる考えが「想像するんじゃなくて思い出す」です。なぜなら想像することは知らないので難しく、思い出すことは知っているので簡単だからです。ソフトウェア開発に当てはめてみると、思い出すためにはRubyユーザーとしての経験が必要です。あとはその経験を思い出せばいいのです。しかし、「思い出す」という経験がないので「思い出す」ことが難しいことでしょう。「思い出す」経験をするためにはライブラリー開発者になることをおすすめします。ライブラリーを開発すると何度も何度も「思い出す」必要があり、とてもよい練習になります。という話をしました。

== 次のステップ

最後にライブラリー開発者になった後の話をして終わりにします。

「ライブラリー開発者」としての経験を他のことにも使ってください。たとえば、他のソフトウェアの開発に使ってください。Rubyでもいいです。他のソフトウェアを開発するときには、よりよいバグレポートはどんなバグレポートだろうとか、よいパッチはどんなパッチだろうとかを「思い出して」ください。例えば、バグレポートなら再現方法があるとうれしいですし、期待する結果もあるとうれしいですね。パッチならわかりやすい単位で分割されているとうれしいですし、適切なコミットメッセージがついているとうれしいですね。ライブラリー開発者としてバグレポートをもらった経験を思い出せばいろいろわかるはずです。

ということで、ライブラリー開発者になりましょう！
