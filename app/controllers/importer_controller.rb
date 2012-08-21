# -*- encoding: utf-8 -*-
class ImporterController < ApplicationController
  unloadable
  before_filter :find_project

  def import
    login, password, repo = params[:login], params[:password], params[:repo]
    client = Octokit::Client.new(:login => login, :password => password)

    puts client

    issues = client.list_issues repo

    issues.each do |issue|
      puts issue.keys
      puts issue
    end

    flash[:notice] = t(:import_complete)
    redirect_to :controller => :importer, :action => :index
  end

  def index

  end
end
