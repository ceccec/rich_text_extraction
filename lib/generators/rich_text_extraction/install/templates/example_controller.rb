# frozen_string_literal: true

# Example controller demonstrating RichTextExtraction usage
# This is a sample controller - you can delete it or use it as a reference

class ExamplePostsController < ApplicationController
  before_action :set_example_post, only: [:show]

  def show
    # Extract various data from the post content
    @links = @example_post.extract_links
    @opengraph_data = @example_post.extract_opengraph_data
    @social_content = @example_post.extract_social_content
    @excerpt = @example_post.excerpt(200)

    # Process links in background if needed
    @example_post.process_links_async if @example_post.has_links?

    respond_to do |format|
      format.html
      format.json do
        render json: {
          post: @example_post,
          links: @links,
          opengraph: @opengraph_data,
          social: @social_content,
          excerpt: @excerpt
        }
      end
    end
  end

  def index
    @example_posts = ExamplePost.all

    # Extract links from all posts
    @all_links = @example_posts.flat_map(&:extract_links).uniq
    @link_count = @all_links.count

    # Get OpenGraph data for all unique links
    @opengraph_data = @all_links.map do |url|
      { url: url, opengraph: extract_opengraph_for_url(url) }
    end
  end

  private

  def set_example_post
    @example_post = ExamplePost.find(params[:id])
  end

  def extract_opengraph_for_url(url)
    # Use the extractor directly for single URLs
    extractor = RichTextExtraction::Extractor.new(url)
    extractor.opengraph_data_for_links.first&.dig(:opengraph) || {}
  rescue StandardError => e
    Rails.logger.error "Failed to extract OpenGraph for #{url}: #{e.message}"
    { error: e.message }
  end
end
