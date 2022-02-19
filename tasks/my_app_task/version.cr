# tasks/generate_sitemaps.cr

require "../../src/my_app.cr"

module MyAppTask
  class Version < LuckyTask::Task
    summary "Print the version of this site"

    def call
      puts "#{MyApp::NAME} version #{MyApp::VERSION}"
    end
  end
end
