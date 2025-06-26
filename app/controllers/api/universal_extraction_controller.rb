# frozen_string_literal: true

class Api::UniversalExtractionController < ApplicationController
  def extract
    result = RichTextExtraction::Universal::InterfaceAdapter.handle_request(type: :extract, data: params[:text], options: params.to_unsafe_h)
    render json: result
  end

  def validate
    result = RichTextExtraction::Universal::InterfaceAdapter.handle_request(type: :validate, data: params[:value], options: params.to_unsafe_h)
    render json: result
  end
end
