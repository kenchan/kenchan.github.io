require 'net/http'
require 'rss'
require 'uri'
require 'date'

class ScrapboxDiaryFeed
  DAYS_TO_KEEP = 30

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
    diary_tagged_items
      .map { |item| prepare_diary_item(item, today) }
      .compact
      .sort_by { |item, date| -date.to_time.to_i }
      .map(&:first)
  end

  def diary_tagged_items
    original_feed.items.select { |item|
      has_date_in_title?(item.title) && item.title !~ /\(WIP\)/
    }
  end

  def prepare_diary_item(item, today)
    date = extract_date_from_item(item)
    return nil unless date
    return nil unless recent?(date, today)

    # pubDateを日記の日付に設定（RSS仕様との整合性のため）
    item.pubDate = date.to_time
    item.title = date.strftime('%Y-%m-%d')
    [item, date]
  end

  def has_date_in_title?(title)
    title.match?(/^\d{4}-\d{2}-\d{2}/)
  end

  def extract_date_from_item(item)
    extract_date_from_title(item.title)
  end

  def extract_date_from_title(title)
    match = title.match(/^(\d{4}-\d{2}-\d{2})/)
    return nil unless match
    Date.parse(match[1])
  end

  def recent?(date, today)
    (today - date).to_i <= DAYS_TO_KEEP
  end
end
