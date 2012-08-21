# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get  'projects/:id/import', :to => 'importer#index'
post 'projects/:id/import', :to => 'importer#import'