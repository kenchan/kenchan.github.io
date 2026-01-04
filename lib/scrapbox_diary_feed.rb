require 'net/http'
require 'rss'
require 'uri'
require 'date'

class ScrapboxDiaryFeed
  attr_reader :project_name

  def initialize(project_name)
    @project_name = project_name
  end

  def url
    "https://scrapbox.io/api/feed/#{@project_name}"
  end

  def items
    @_items ||= select_diary_items
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
    @_original_feed ||= begin
      response = Net::HTTP.get(URI.parse(url))
      RSS::Parser.parse(response)
    rescue StandardError => e
      warn "Failed to fetch or parse feed from #{url}: #{e.message}"
      raise
    end
  end

  private
  def select_diary_items
    today = Date.today
    @_diary_items ||= original_feed.items.select {|item|
      item.description =~ /#日記/ && item.title !~ /\(WIP\)/
    }.map {|item|
      match = item.description.match(/#(\d{4}-\d{2}-\d{2})/)
      next unless match

      date_str = match[1]
      date = Date.parse(date_str)
      next unless (today - date).to_i <= 30

      # pubDateを日記の日付に設定（RSS仕様との整合性のため）
      item.pubDate = date.to_time
      item.title = date_str
      [item, date]
    }.compact.sort_by {|item, date|
      -date.to_time.to_i
    }.map {|item, date|
      item
    }
  end
end
