require 'bundler'
require 'pp'
require 'open-uri'
Bundler.require

### xPathやディレクトリ修正などロジック部分についてはページごとによって修正必要あり
### ざっくりこんな構成で作るというイメージ
### [TODO]もう少し汎用的にできそう

PAGE_COUNT = 20 #ページ数
IMG_COUNT = 20 #画像の数
CHILD_PAGE_ID = "p4" #ページングでトップページから階層を掘る場合のID

# ページリストを取得
def getPageUrls(url)
  doc = Nokogiri::HTML(open(url))
  pageUrl = Array.new

  (0..PAGE_COUNT-1).each do |i|
    nodes = doc.xpath("//*[@id='columnList']/div[2]/ul/li[#{i+1}]/a")
    nodes.each do |node|
      dir = node.attributes['href'].value
      pageUrl[i] = url + File.basename(dir) 
      pageUrl[i] = pageUrl[i].sub(/\/#{CHILD_PAGE_ID}/, '')  # ページング部分のIDを削除
    end
  end
  return pageUrl
end

# 画像のurlリストを取得
def getImgUrls(pageUrl)
  imgUrls = Array.new
  (0..IMG_COUNT-1).each do |i|
    pageUrlChild = pageUrl + "/" + (i+1).to_s
    doc = Nokogiri::HTML(open(pageUrlChild))
    nodes = doc.xpath("//*[@id='columnContents']/div[2]/div/a/img") #chromeのdevtoolで取得しておく
    nodes.each do |node|
      imgUrls[i] = node.attributes['src'].value
    end
  end
  return imgUrls
end

# urlリストをwriteImgを呼び出して保存していく
def writeImgs(urls)
  (0..urls.length-1).each do |i|
    writeImg(urls[i])
  end
end

# 画像の書き込み
def writeImg(url)
  # ファイルパス設定
  urlFixed = url.sub(/\/w600h450\//, '')  #不要ディレクトリの削除
  fileName = File.basename(urlFixed)
  dirName = "./img/"
  filePath = dirName + fileName

  pp filePath
  # imgフォルダの作成
  FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)

  # 書き込み
  open(filePath, 'wb') do |output|
    open(url) do |data|
      output.write(data.read)
    end
  end
end

def main
  url = "対象のURLをいれる" + CHILD_PAGE_ID + "/"

  # ページ一覧を取得
  pageUrls = getPageUrls(url)

  pp pageUrls
  # 各ページごとに実行
  (0..pageUrls.length-1).each do |i|
    # 画像URL一覧取得
    imgUrls = getImgUrls(pageUrls[i])

    # 画像を保存
    writeImgs(imgUrls)

    pp "[finished] #{pageUrls[i]}"
  end
end

if __FILE__ == $0
  main
end