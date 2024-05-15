require 'elasticsearch/model'

$elasticsearchClient  = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200')

# test elastic search connection and bybass the application if it is not available
begin
    $elasticsearchClient.cluster.health
    puts "Elasticsearch is available!!!!!! horaaay"
rescue
    puts "Elasticsearch is not available, bypassing the application"
    exit 1
end