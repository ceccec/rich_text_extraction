# frozen_string_literal: true

Rails.application.routes.draw do
  # RichTextExtraction Validator API routes
  get '/validators', to: 'rich_text_extraction/validators#index'
  get '/validators/fields', to: 'rich_text_extraction/validators#fields'
  get '/validators/:id', to: 'rich_text_extraction/validators#show'
  get '/validators/:id/jsonld', to: 'rich_text_extraction/validators#jsonld'
  get '/validators/:id/examples', to: 'rich_text_extraction/validators#examples'
  get '/validators/:id/regex', to: 'rich_text_extraction/validators#regex'
  post '/validators/:id/validate', to: 'rich_text_extraction/validators#validate'
  post '/validators/:id/batch_validate', to: 'rich_text_extraction/validators#batch_validate'
  match '/validators/:id', to: 'rich_text_extraction/validators#options', via: [:options]

  # Defines the root path route ("/")
  # root "posts#index"
end
