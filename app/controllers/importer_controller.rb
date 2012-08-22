# -*- encoding: utf-8 -*-
require 'hashie'
class ImporterController < ApplicationController
  unloadable
  before_filter :find_project
  attr_accessor :user_map
  attr_accessor :dumper

  def index
    if dump = fresh_dump
      @user_map = {}
      dump.users.each do |login|
        @user_map[login] = nil
      end
    end
  end

  def import
    unless dump = fresh_dump
      flash[:notice] = t(:no_dump_to_import)
      redirect_to :controller => :importer, :action => :index
      return
    end

    importer = Octomine::Importer.new logger
    user_map = importer.import_users YAML.load(params[:user_map]), User.current, params[:create_missing_users]

    user_map.each do |k, v|
      logger.info "#{k}: [#{v.id}, #{v.login}]"
    end

    default_tracker_id = Tracker.first.id
    closed_status_id   = IssueStatus.find_by_is_closed(true).id
    open_status_id     = IssueStatus.find_by_is_default(true).id
    importer.import_issues @project.id, default_tracker_id, user_map, dump, closed_status_id, open_status_id

    flash[:notice] = t(:import_complete)
    redirect_to :controller => :importer, :action => :index
  end

  def dump
    login, password, repo = params[:login], params[:password], params[:repo]

    begin
      dumper = Octomine::Dumper.new login, password, repo
      logger.info "Dumper found #{dumper.issues.length} issues and #{dumper.comments.length} on the repo #{repo}"

      github_dump = File.open(Rails.root.join('tmp/github_dump'), 'w')
      github_dump.print(YAML.dump(dumper))
      session[:github_dump] = github_dump.path
      github_dump.flush
      logger.info "#{File.size(session[:github_dump])} bytes written to #{session[:github_dump]}"
    rescue => e
      flash[:error] = "[#{e.class}] #{e.message}"
    end

    flash[:notice] = t(:dump_complete)
    redirect_to :controller => :importer, :action => :index
  end

  def clear
    File.unlink(session[:github_dump]) if session[:github_dump] && File.exists?(session[:github_dump])
    session[:github_dump] = nil

    flash[:notice] = t(:dump_removed)
    redirect_to :controller => :importer, :action => :index
  end

  def fresh_dump
    return nil unless session[:github_dump]
    unless File.exists?(session[:github_dump])
      flash[:warning] = "Dump file expired #{session[:github_dump]}"
      session[:github_dump] = nil
      return nil
    end
    return @dumper if @dumper
    @dumper = YAML.load(File.read(session[:github_dump]))
  end
end
