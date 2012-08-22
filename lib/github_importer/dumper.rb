# -*- encoding : utf-8 -*-
module GithubImporter
  class Dumper
    attr_accessor :client
    attr_accessor :issues

    def initialize login, password, repo
      @repo = repo
      @client = Octokit::Client.new(:login => login, :password => password)
    end

    def issues
      return @issues if @issues
      save_auto_traversal = client.auto_traversal
      client.auto_traversal = true
      closed_issues = client.list_issues(@repo, { :state => 'closed' })
      open_issues   = client.list_issues(@repo)
      @issues = []
      @issues.concat(closed_issues).concat(open_issues)
      client.auto_traversal = save_auto_traversal
      @issues
    end

    def users
      return @users if @users
      @users = Set.new
      issues.each do |issue|
        @users.add(issue.user.login) if issue.respond_to?(:user) && issue.user
        @users.add(issue.assignee.login) if issue.respond_to?(:assignee) &&  issue.assignee
      end
      @users
    end

    def issue_comments number
      client.issue_commits(@repo, number)
    end
  end
end