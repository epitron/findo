require 'elasticsearch'

class Result < Struct.new(:id, :score, :data)
  def initialize(result)
    super *result.values_at("_id", "_score", "_source")
  end
end

class Time
  def json_date
    # "yyyy/MM/dd HH:mm:ss"
    strftime("%Y-%m-%dT%H:%M:%S")
  end
end

class FileIndex

  attr_accessor :client

  def initialize(log: false)
    @client = Elasticsearch::Client.new log: log
  end

  def reset!
    client.indices.delete index: "files"
  end

  def all
  end

  def add(path)
    path = Path[path]

    blacklisted_xattrs = %w[user.com.dropbox.attributes]
    xattrs = path.xattrs.delete_if { |k,v| blacklisted_xattrs.include? k }

    if path.dir?
      name = path.dirs.last
      dir = path.dirs[0..-2].join("/")
    else
      name = path.basename
      dir = path.dir
    end

    client.index index: "files", id: path.path, type: "file", body: { 
      name:   name,
      ext:    path.ext,
      dir:    dir,
      size:   path.size,
      ctime:  path.ctime.json_date,
      date:   path.mtime.json_date,
      xattrs: xattrs
    }
  end
  alias << add

  def delete(path)
    client.delete index: "files", type: "file", id: path
  end

  def search(query_string)
    if query_string.empty?
      #show everything
      client.search
    else
      # http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html    
      response = client.search index: "files", body: { 
        query: {
          query_string: {
            query:         query_string,
            default_field: "name",
          }
        } 
      }
    end

    response["hits"]["hits"].map { |hit| Result.new(hit) }
  end

end

