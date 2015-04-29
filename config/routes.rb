SplImporter::Application.routes.draw do
  root to: 'import_sessions#index'
  resources :import_sessions, only: :index
  get "/auth/:provider/callback" => 'import_sessions#success'
  get "/auth/failure" => 'import_sessions#failure'
end