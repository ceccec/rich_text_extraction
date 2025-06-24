# frozen_string_literal: true

# Example background job demonstrating RichTextExtraction usage
# This is a sample job - you can delete it or use it as a reference

class ProcessLinksJob < ApplicationJob
  queue_as :default

  def perform(post)
    return unless post.respond_to?(:content) && post.content.present?

    Rails.logger.info "Processing links for post #{post.id}"

    # Extract links from the post content
    links = post.content.links
    return if links.empty?

    Rails.logger.info "Found #{links.count} links in post #{post.id}"

    # Process each link
    links.each do |url|
      process_link(url, post)
    end

    # Store processed data
    store_processed_data(post, links)

    Rails.logger.info "Finished processing links for post #{post.id}"
  rescue StandardError => e
    Rails.logger.error "Error processing links for post #{post.id}: #{e.message}"
    raise e
  end

  private

  def process_link(url, post)
    Rails.logger.debug "Processing link: #{url}"

    # Extract OpenGraph data
    opengraph_data = extract_opengraph_data(url)

    # Store the data (you can customize this)
    store_link_data(post, url, opengraph_data)

    # Additional processing based on link type
    case url
    when /twitter\.com/
      process_twitter_link(url, opengraph_data)
    when /youtube\.com/
      process_youtube_link(url, opengraph_data)
    when /github\.com/
      process_github_link(url, opengraph_data)
    else
      process_generic_link(url, opengraph_data)
    end
  end

  def extract_opengraph_data(url)
    extractor = RichTextExtraction::Extractor.new(url)
    data = extractor.opengraph_data_for_links.first
    data ? data[:opengraph] : {}
  rescue StandardError => e
    Rails.logger.warn "Failed to extract OpenGraph for #{url}: #{e.message}"
    { error: e.message, url: url }
  end

  def store_link_data(post, url, opengraph_data)
    # Store in cache
    cache_key = "post_#{post.id}_link_#{Digest::MD5.hexdigest(url)}"
    Rails.cache.write(cache_key, opengraph_data, expires_in: 1.hour)

    # You could also store in database
    # LinkData.create!(
    #   post: post,
    #   url: url,
    #   opengraph_data: opengraph_data,
    #   processed_at: Time.current
    # )
  end

  def store_processed_data(post, links)
    # Store summary data
    summary = {
      link_count: links.count,
      processed_at: Time.current,
      urls: links
    }

    Rails.cache.write("post_#{post.id}_links_summary", summary, expires_in: 1.hour)
  end

  def process_twitter_link(url, _opengraph_data)
    Rails.logger.info "Processing Twitter link: #{url}"
    # Add Twitter-specific processing logic
  end

  def process_youtube_link(url, _opengraph_data)
    Rails.logger.info "Processing YouTube link: #{url}"
    # Add YouTube-specific processing logic
  end

  def process_github_link(url, _opengraph_data)
    Rails.logger.info "Processing GitHub link: #{url}"
    # Add GitHub-specific processing logic
  end

  def process_generic_link(url, _opengraph_data)
    Rails.logger.info "Processing generic link: #{url}"
    # Add generic link processing logic
  end
end
