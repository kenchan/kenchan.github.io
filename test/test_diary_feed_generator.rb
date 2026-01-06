require 'minitest/autorun'
require 'rss'
require_relative '../lib/diary_feed_generator'

class TestDiaryFeedGenerator < Minitest::Test
  def test_generate_returns_valid_rss
    generator = DiaryFeedGenerator.new
    rss_string = generator.generate

    assert_kind_of String, rss_string
    refute_empty rss_string

    rss = RSS::Parser.parse(rss_string)
    assert_equal 'kenchanの日記', rss.channel.title
    assert_equal 'https://scrapbox.io/kenchan', rss.channel.link
  end

  def test_generate_includes_items
    generator = DiaryFeedGenerator.new
    rss_string = generator.generate

    rss = RSS::Parser.parse(rss_string)
    refute_empty rss.items
  end
end
