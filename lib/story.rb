require 'active_resource'

class Story < ActiveResource::Base
  include Comparable

  def self.yaml
    YAML.load_file('slurper_config.yml')
  end

  def self.config(project_id='project_id')
    @@config = yaml
    scheme =  if !!@@config['ssl']
                self.ssl_options = {  :verify_mode => OpenSSL::SSL::VERIFY_PEER,
                                      :ca_file => File.join(File.dirname(__FILE__), "cacert.pem") }
                "https"
              else
                "http"
              end
    self.site = "#{scheme}://www.pivotaltracker.com/services/v3/projects/:project_id"
    # self.site = "#{scheme}://www.pivotaltracker.com/services/v3/projects/#{@@config[project_id]}"
    @@config
  end

  headers['X-TrackerToken'] = config.delete("token")
  headers['Accept-Encoding'] = '*/*'
  self.format = ActiveResource::Formats::XmlFormat

  def prepare
    scrub_description
    scrub_labels
    default_requested_by
    self.description += "\n" + "Label Search\n" + label_search_url + "\n\n" + story_links.join("\n") if epic_story?
  end

  def epic_story?
    respond_to?(:labels) ? self.labels.split(',').include?("epic") : false
  end

  def feature_labels
    self.labels.split(',').find { |label| label != "epic" }
  end

  def save
    @config ||= Story.yaml
    self.prefix_options = {:project_id => @config['project_id']}
    super
  end

  def <=>(another_story)
    if self.epic_story? && another_story.epic_story?
      0
    elsif self.epic_story? && !another_story.epic_story?
      -1
    elsif !self.epic_story? && !another_story.epic_story?
      0
    else
      1
    end
  end

  protected

  def label_search_url
    @config ||= Story.yaml
    "https://www.pivotaltracker.com/projects/#{@config['epic_features_project_id']}?label=" + feature_labels
  end

  def story_links
    retrieve_user_stories.map { |story| story.url }
  end

  def retrieve_user_stories
    @config ||= Story.yaml
    stories = Story.find(:all, :params => {:filter => 'label:' + feature_labels, :project_id => @config['epic_features_project_id']})
  end

  def scrub_description
    if respond_to?(:description)
      self.description = description.gsub("  ", "").gsub(" \n", "\n")
    end
    if respond_to?(:description) && description == ""
      self.attributes["description"] = nil
    end
  end

  def scrub_labels
    if respond_to?(:labels)
      self.labels = labels.gsub(" ", "").gsub(" \n", "\n")
    end
  end

  def default_requested_by
    if (!respond_to?(:requested_by) || requested_by == "") && Story.config["requested_by"]
      self.attributes["requested_by"] = Story.config["requested_by"]
    end
  end

end
