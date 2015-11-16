require 'spec_helper'
describe AuRec do
  let(:rec){AuRec.new(1, 'a', [])}
  it 'has the right id' do
    expect(rec.id).to eq '1'
  end

  it 'holds the right old_id value' do
    expect(rec.old_id).to eq 'a'
  end

  it 'knows if has refs' do
    expect(rec.refs_to?).to be_falsey
    rec.refs_to << 'a'
    expect(rec.refs_to?).to be_truthy
  end

  it 'refs_to is a mutable array' do
    expect(rec.refs_to).to be_an Array
    expect(rec.refs_to).to be_empty 
    rec.refs_to << 'a'
    expect(rec.refs_to).not_to be_empty
  end

  it 'refs_from is a mutable array' do
    expect(rec.refs_from).to be_an Array
    expect(rec.refs_from).to be_empty 
    rec.refs_from << 'a'
    expect(rec.refs_from).not_to be_empty
  end
end
describe JsonDb do
  include_context :sharable 

  let(:parser){JsonDb.build(sample)}

  it "reads correctly the number of records" do
    parser#you should invoke this before getting access to the actual instances of the class
    expect(JsonDb.count).to eq 4
  end
  it "each record is an instance  of AuRec" do
    parser.each do |rec|
      expect(rec).to be_an AuRec
    end
  end

  it "finds by record identifier" do
    expect(parser.find_by_id('oid1')).to be_an AuRec
    expect(parser.find_by_id('xxx')).to be_nil
  end

  it "returns the right record" do
    rec = parser.find_by_id('oid1')
    expect(rec.id).to eq '1'
    expect(rec.old_id).to eq 'oid1'
  end

  it "build correctly references for both sides" do
    rec = parser.find_by_id('oid2')
    expect(rec.refs_to).to match_array ['oid1', 'oid4']
    expect(rec.refs_from).to match_array ['oid3']
  end



end
