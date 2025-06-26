# frozen_string_literal: true

RichTextExtraction::Engine.routes.draw do
  # Validator API routes
  get '/validators', to: 'validators#index'
  get '/validators/fields', to: 'validators#fields'
  get '/validators/:id', to: 'validators#show'
  get '/validators/:id/jsonld', to: 'validators#jsonld'
  get '/validators/:id/examples', to: 'validators#examples'
  get '/validators/:id/regex', to: 'validators#regex'
  post '/validators/:id/validate', to: 'validators#validate'
  post '/validators/:id/batch_validate', to: 'validators#batch_validate'
  match '/validators/:id', to: 'validators#options', via: [:options]
end
