SplImporter::Application.routes.draw do
  root to: 'sessions#new'
  resources :sessions, only: :index
  get "/auth/:provider/callback" => 'sessions#success'
  get "/auth/failure" => 'sessions#failure'
end