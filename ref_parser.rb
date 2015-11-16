require 'json'
class DataSplitter
  class << self
    def split( json_data )
      recs = {}
      json_data.split("\n").each do |entry|
        j = JSON.parse(entry)
        rec = AuRec.new(j['id'], j['old_id'], j['refs'])
        recs[j['old_id']] = rec 
      end
      recs
    end
  end
end
class AuRec
  attr_accessor :id, :old_id, :refs_to, :refs_from
  def initialize(id, old_id, refs)
    @id = id.to_s
    @old_id = old_id.to_s
    @refs_to = refs 
    @refs_from = []
  end
  def refs_to?
    !@refs_to.empty?
  end
  def refs_from?
    !@refs_from.empty?
  end
end

class JsonDb
  attr_reader :records
  class << self
    attr_accessor :count
    def build( data  )
      JsonDb.new( data )
    end
    def count
      @count ||= 0
    end
  end
  def initialize( json_data )
    @records = DataSplitter.split( json_data ) 
    JsonDb.count = @records.length
    build_internal_links unless @records.empty?
  end

  def each(&block)
    @records.each_value(&block)
  end

  def find_by_id( value  )
    @records[value.to_s]
  end
  
  %w(to from).each do |x|
    define_method "#{x}_references" do |&b|
      actual_records.select{|i| i.method("refs_#{x}?".to_sym).call }.each(&b)
    end
  end

  private
  def actual_records
    @records.values
  end

  def build_internal_links
    to_references do |ref|
      ref.refs_to.each do |ref_id|
        rec = find_by_id( ref_id ) 
        rec.refs_from << ref.old_id if rec
      end
    end
  end
end