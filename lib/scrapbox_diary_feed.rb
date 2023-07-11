require 'net/http'
require 'rss'
require 'uri'

class ScrapboxDiaryFeed
  attr_reader :project_name

  def initialize(project_name)
    @project_name = project_name
  end

  def url
    "https://scrapbox.io/api/feed/#{@project_name}"
  end

  def items
    @_items ||= select_diary_itemes
  end

  def title
    original_feed.channel.title
  end

  def last_updated
    items.first.pubDate
  end

  def description
    original_feed.channel.description
  end

  def link
    original_feed.channel.link
  end

  def original_feed
    @_original_feed ||= RSS::Parser.parse(Net::HTTP.get(URI.parse(url)))
  end

  private
  def select_diary_itemes
    @_diary_items ||= original_feed.items.select {|item|
      item.description =~ /#日記/ && item.title =~ /^2023/ && item.title !~ /\(WIP\)/
    }.map {|item|
      item.title = item.title.split(' - ').first
      item
    }
  end
end
