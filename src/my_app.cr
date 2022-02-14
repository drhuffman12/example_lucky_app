module MyApp
  NAME = "MyApp"
  GIT_COMMIT = `git log --oneline | head -1`
  VERSION = "#{`shards version`.split.first}(#{GIT_COMMIT.split.first})"
end

# puts MyApp::VERSION
