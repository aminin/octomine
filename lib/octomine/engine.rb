# -*- encoding : utf-8 -*-
module Octomine
  module Engine
    class Engine < Rails::Engine
      #isolate_namespace ::Neko::Analyzer
      engine_name 'neko_analyzer'

      # @param [Rails::Application] app
      initializer 'octomine.configure_rails_initialization' do |app|
        Redmine::Plugin.register :octomine do
          name 'Octomine'
          author 'Author name'
          description 'Github importer plugin'
          version Octomine::VERSION
          url 'http://github.com/aminin/octomine'
          author_url 'http://github.com/aminin'

          permission :github_import, { :importer => [:index, :import] }, :public => true
          menu :project_menu, :octomine, { :controller => 'importer', :action => 'index' }, :caption => 'GitHub Import', :last => true
        end
      end
    end
  end
end