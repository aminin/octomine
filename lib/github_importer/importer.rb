# -*- encoding : utf-8 -*-
module GithubImporter
  class Importer
    def initialize logger
      @logger = logger
    end

    def import_users user_map, default_user, create_missing_users = true
      user_map = user_map.map do |gh_login, rm_login|
        rm_login ||= gh_login
        unless user = User.find_by_login(rm_login)
          if create_missing_users
            logger.info "Creating missing user #{rm_login}"
            user = User.new
            user.login = rm_login
            user.firstname = rm_login.capitalize
            user.lastname  = 'On GitHub'
            user.mail      = "#{gh_login}@example.com"
            logger.warn("Errors occurred while saving user '#{rm_login}' #{user.errors.messages}") unless user.save
          end
          user ||= default_user
        end
        [gh_login, user]
      end.flatten!
      Hash[*user_map]
    end

    def import_issues project_id, tracker_id, user_map, issues, closed_status_id = nil, open_status_id = nil
      logger.debug "Number of issues to import is #{issues.length}"
      issues.each do |gh_issue|
        logger.debug "Importing issue #{gh_issue.number} #{gh_issue.title}"
        if gh_issue.pull_request && gh_issue.pull_request.empty? && gh_issue.pull_request.diff_url && !gh_issue.pull_request.diff_url.empty?
          logger.debug "Skipping pull request"
          logger.debug gh_issue.pull_request.inspect
          next
        end
        rm_issue = Issue.find_by_id(gh_issue.number) || Issue.new
        rm_issue.id          = gh_issue.number
        # Project is required
        rm_issue.project_id  = project_id
        # Subject is required
        rm_issue.subject     = gh_issue.title
        rm_issue.description = gh_issue.body
        # Author is required
        rm_issue.author_id   = user_map[gh_issue.user.login].id
        # Tracker is required
        rm_issue.tracker_id  = tracker_id

        rm_issue.assigned_to_id = user_map[gh_issue.assignee.login].id if gh_issue.assignee
        rm_issue.status_id = closed_status_id if gh_issue.state == 'closed'
        rm_issue.status_id = open_status_id   if gh_issue.state == 'open'
        rm_issue.created_on = gh_issue.created_at

        if rm_issue.save
          logger.debug 'Issue successfully saved'
        else
          logger.debug "Error ocured while saving issue #{rm_issue.errors.messages}"
        end

        if gh_issue.comments && gh_issue.comments.to_i > 0
          logger.warn 'TODO: import comments'
        end
      end
    end

    private
    def logger
      @logger
    end
  end
end