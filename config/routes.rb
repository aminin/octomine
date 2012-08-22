# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get  'projects/:id/importer', :to => 'importer#index'
post 'projects/:id/importer/import', :to => 'importer#import'
post 'projects/:id/importer/dump', :to => 'importer#dump'