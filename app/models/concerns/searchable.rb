module Searchable
    extend ActiveSupport::Concern
    included do
        include Elasticsearch::Model
        include Elasticsearch::Model::Callbacks

        settings :analysis => {
                :filter => {
                    :ngram_filter => {
                        :type => "edge_ngram",
                        :min_gram => 1,
                        :max_gram => 15
                    }
                },
                :analyzer => {
                    :ngram_analyzer => {
                        :type => "custom",
                        :tokenizer => "standard",
                        :filter => [
                            "lowercase",
                            "ngram_filter"
                        ]
                    
                }
            }
       }

        settings do
            mapping dynamic: false do
                indexes :body, type: :text, analyzer: 'ngram_analyzer'
            end
        end 

        def self.search(query)
            __elasticsearch__.search(
                {
                "query": {
                    "match": {
                        "body": {
                        "query": "#{query}",
                        "analyzer": "standard"
                        }
                    } 
                    }
                }
            )

        end

        def as_indexed_json(options = nil)
            self.as_json( only: [ :number, :body] )
        end

        unless Message.__elasticsearch__.index_exists?
            Message.__elasticsearch__.create_index!
        end
        Message.import
    end
end
