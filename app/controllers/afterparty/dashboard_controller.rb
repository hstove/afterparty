module Afterparty
  class DashboardController < ApplicationController
    before_filter :authenticate
    layout false
    before_filter :find_job, only: [:run, :destroy, :run_again]

    def index
      @queues = Afterparty.queues
      if params[:completed]
        @jobs = AfterpartyJob.completed.limit(20)
      else
        @jobs = queue.jobs
      end
    end

    def run
      queue.run @job
      flash[:notice] = "You successfully completed job ##{@job.id}."
      redirect_to afterparty_engine.dashboard_path(completed: true)
    end

    def destroy
      @job.destroy
      flash[:notice] = "You have successfully destroyed job ##{@job.id}."
      redirect_to afterparty_engine.dashboard_path
    end

    private

    def queue
      Rails.configuration.queue
    end

    def find_job
      @job = AfterpartyJob.find(params[:id])
    end

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        queue.authenticate(username, password)
      end
    end
  end
end