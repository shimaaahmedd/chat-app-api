module Searchable
    extend ActiveSupport::Concern
    included do
        include Elasticsearch::Model
        include Elasticsearch::Model::Callbacks

        unless Message.__elasticsearch__.index_exists?
            Message.__elasticsearch__.create_index!
          end
          Message.import
        end
    
        settings do
            mapping dynamic: false do
            indexes :body, type: :text, analyzer: 'english'
            end
        end
        
        def self.search(query)
           response =  __elasticsearch__.search(
                {
                "query": {
                    "bool": {
                    "must": [
                        {
                        "multi_match": {
                            "query": "*#{query}*",
                            "fields": ["body"]
                        }
                        }
                    ]
                    }
                }, 
                "fields": ["number","body"]
                }
            )
            # response.results.map { |r| body = r._source.body, number = r._source.number, user_id = r._source.user_id }

        end

        def as_indexed_json(options = nil)
            self.as_json( only: [ :body ] )
        end
    end
end
