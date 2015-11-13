require 'json'
class AuRec
  attr_accessor :id, :old_id, :refs_to, :refs_from
  def initialize(id, old_id, refs)
    @id = id.to_s
    @old_id = old_id.to_s
    @refs_to = refs 
    @refs_from = []
  end
  def has_refs?
    !@refs_to.empty?
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
    @records = {}
    json_data.split("\n").each do |entry|
      j = JSON.parse(entry)
      rec = AuRec.new(j['id'], j['old_id'], j['refs'])
      @records[j['old_id']] = rec 
    end
    build_internal_links unless @records.empty?
    JsonDb.count = @records.length
  end

  def each(&block)
    @records.each_value(&block)
  end

  def find_by_id( value  )
    @records[value.to_s]
  end

  def references(&block)
    actual_records.select{|i| i.has_refs?}.each(&block)
  end

  private
  def actual_records
    @records.values
  end

  def build_internal_links
    references do |ref|
      ref.refs_to.each do |ref_id|
        rec = find_by_id( ref_id ) 
        rec.refs_from << ref.old_id if rec
      end
    end
  end
end