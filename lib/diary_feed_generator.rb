require_relative 'scrapbox_diary_feed'

require 'rss'

class DiaryFeedGenerator
  def generate
    feed = ScrapboxDiaryFeed.new('kenchan')

    rss = RSS::Maker.make('2.0') do |maker|
      maker.channel.title = "#{feed.title.split(' - ').first}の日記"
      maker.channel.link = feed.link
      maker.channel.updated = feed.last_updated
      maker.channel.description = feed.description

      feed.items.each do |scrapbox_item|
        maker.items.new_item do |item|
          item.title = scrapbox_item.title
          item.link = scrapbox_item.link
          item.content_encoded = scrapbox_item.description
          item.updated = scrapbox_item.pubDate
        end
      end
    end

    rss.to_s
  end
end
