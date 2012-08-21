Redmine::Plugin.register :github_importer do
  name 'Github importer plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  permission :github_import, { :importer => [:index, :import] }, :public => true
  menu :project_menu, :github_importer, { :controller => 'importer', :action => 'index' }, :caption => 'GitHub Import', :last => true
end
