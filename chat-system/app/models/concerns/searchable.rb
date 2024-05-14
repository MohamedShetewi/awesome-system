module Searchable
    extend ActiveSupport::Concern
  
    included do
        include Elasticsearch::Model
        include Elasticsearch::Model::Callbacks
  
        mapping do
            indexes :appID, type: 'integer'
            indexes :chatID, type: 'integer'
            indexes :messageID, type: 'integer'
            indexes :message, type: 'text'
        end
    
        def self.search(query)
            __elasticsearch__.search(
                {
                    query: {
                        multi_match: {
                            query: query,
                            fields: ['message']
                        }
                    },
            })
        end
    end
end