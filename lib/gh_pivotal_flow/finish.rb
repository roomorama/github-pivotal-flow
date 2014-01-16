# The class that encapsulates finishing a Pivotal Tracker Story
module GhPivotalFlow
  class Finish < Command

    # Finishes a Pivotal Tracker story by doing the following steps:
    # * Check that the pending merge will be trivial
    # * Merge the development branch into the root branch
    # * Delete the development branch
    # * Push changes to remote
    #
    # @return [void]
    def run!
      story = @configuration.story(@project)
      story.can_merge?
      commit_message = @options[:args].last.dup if @options[:args].last
      story.merge_to_root!(commit_message, @options) unless options[:no_merge]
      Git.publish(story.root_branch_name)
      return 0
    end

    private

    def parse_argv(*args)
      OptionParser.new do |opts|
        opts.banner = "Usage: git finish [options]"
        opts.on("-t", "--api-token=", "Pivotal Tracker API key") { |k| options[:api_token] = k }
        opts.on("-p", "--project-id=", "Pivotal Tracker project id") { |p| options[:project_id] = p }
        opts.on("-n", "--full-name=", "Your Pivotal Tracker full name") { |n| options[:full_name] = n }
        opts.on("-m", "--message=", "Specify a commit message") { |m| options[:commit_message] = m }

        opts.on("--no-complete", "Do not mark the story completed on Pivotal Tracker") { options[:no_complete] = true }
        opts.on("--no-merge", "Do not merge pull request") { options[:no_merge] = true }
        opts.on_tail("-h", "--help", "This usage guide") { put opts.to_s; exit 0 }
      end.parse!(args)
    end
  end
end