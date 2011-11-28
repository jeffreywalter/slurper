require 'yaml'
require 'story'

YAML::ENGINE.yamler='syck' if RUBY_VERSION > '1.9'


class Slurper

  attr_accessor :story_file, :stories, :update_epics, :story_query

  def self.slurp(story_file, options)
    
    slurper = new(story_file, options)

    slurper.load_stories
    slurper.prepare_stories
    slurper.sort_stories(options[:reverse])
    slurper.create_stories
  end

  def initialize(story_file, options)
    self.story_file = story_file
    self.update_epics = options[:update_epics]
    self.story_query = options[:story_query]
  end

  def load_stories
    if update_epics
      self.stories = Story.find_unlinked_epics(story_query)
    else
      self.stories = YAML.load(yamlize_story_file)
    end
  end

  def prepare_stories
    stories.each { |story| story.prepare }
  end

  def sort_stories(reverse)
    stories.sort!
    stories.reverse! unless reverse
  end

  def create_stories
    puts "Preparing to slurp #{stories.size} stories into Tracker..."
    stories.each_with_index do |story, index|
      begin
        if story.save
          puts "#{index+1}. #{story.name}"
        else
          puts "Slurp failed. #{story.errors.full_messages}"
        end
      rescue ActiveResource::ConnectionError => e
        msg = "Slurp failed on story "
        if story.attributes["name"]
          msg << story.attributes["name"]
        else
          msg << "##{options[:reverse] ? index + 1 : stories.size - index }"
        end
        puts msg + ".  Error: #{e}"
      end
    end
  end

  protected

  def yamlize_story_file
    IO.read(story_file).
      gsub(/^/, "    ").
      gsub(/    ==.*/, "- !ruby/object:Story\n  attributes:").
      gsub(/    description:$/, "    description: |")
  end

end
