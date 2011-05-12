require 'rubygems'
require 'open-uri'
require 'nokogiri'


lib_dir = File.expand_path('lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

URL_BASE = "http://groups.google.com/group/"


configure do
  set :app_file, __FILE__
end

get "/*" do

  url_base = "http://groups.google.com/group/"
  thread_ =  params["splat"]
  thread_link  = "#{url_base}#{thread_}"

  target = open("#{thread_link}").read

  scraper = Nokogiri::HTML(target)

  items = []
  title = scraper.search("#thread_subject_site").text

  scraper.search("#msgs div.msg").each do |msg|
    _id =  msg.attr("id")
    items << {  :_id => _id,   :link => "#{thread_link}##{_id}",  :title => (msg/".author span").text,  :description => (msg/".mb.cb div").to_xml(:indent => 5, :encoding => 'UTF-8' ),  :pub_date => (msg/"#hdn_date").attr("value")}
  end

  rss  = '<?xml version="1.0"?>'
  rss += '<rss version="2.0"  charset="utf-8">'
  rss += "<channel><title>#{title}</title><link>#{thread_link}</link><description>#{title}</description><pubDate>#{items[0][:pub_date]}</pubDate><lastBuildDate>#{items.reverse[0][:pub_date]}</lastBuildDate>"

  items.each do |item|
    rss += "<item>
         <title>#{item[:title]}</title>
         <link>#{item[:link]}</link>
         <description><![CDATA[#{item[:description]}]]></description>
         <pubDate>#{item[:pub_date]}</pubDate>
         <guid>#{item[:_id]}</guid>
      </item>"
  end
  rss += '</channel></rss>'
  rss
end

