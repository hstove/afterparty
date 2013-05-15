module Afterparty
  class DashboardController < ApplicationController
    layout false
    def index
      @queues = Afterparty.queues
      if params[:completed]
        @jobs = queue.completed_with_scores
      else
        @jobs = queue.jobs_with_scores
      end
    end

    def queue
      Rails.configuration.queue
    end

    def run
    end
  end
end