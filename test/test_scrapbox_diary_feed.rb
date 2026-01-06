require 'minitest/autorun'
require 'date'
require_relative '../lib/scrapbox_diary_feed'

class TestScrapboxDiaryFeed < Minitest::Test
  def setup
    @feed = ScrapboxDiaryFeed.new('test_project')
  end

  def test_has_date_in_title
    assert @feed.send(:has_date_in_title?, '2026-01-03: 実家の片付け - kenchan - Cosense')
    assert @feed.send(:has_date_in_title?, '2026-01-05: (WIP) - kenchan - Cosense')
    refute @feed.send(:has_date_in_title?, 'タイトルに日付なし - kenchan - Cosense')
  end

  def test_extract_date_from_title
    date = @feed.send(:extract_date_from_title, '2026-01-03: 実家の片付け - kenchan - Cosense')
    assert_equal Date.new(2026, 1, 3), date

    date = @feed.send(:extract_date_from_title, 'タイトルに日付なし')
    assert_nil date
  end

  def test_recent?
    today = Date.new(2026, 1, 6)

    assert @feed.send(:recent?, Date.new(2026, 1, 6), today)
    assert @feed.send(:recent?, Date.new(2025, 12, 7), today)
    refute @feed.send(:recent?, Date.new(2025, 12, 6), today)
    refute @feed.send(:recent?, Date.new(2025, 11, 1), today)
  end

  def test_url
    assert_equal 'https://scrapbox.io/api/feed/test_project', @feed.url
  end

  def test_project_name
    assert_equal 'test_project', @feed.project_name
  end
end
