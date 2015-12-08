require 'spec_helper'
describe Rec do
	let(:rec){Rec.new('1', 'a')}
	it_behaves_like 'a record', Rec.new('1', 'q')

	it 'has an id' do
		expect(rec.id).to eq '1'
	end
	it 'has an old_id' do
		expect(rec.old_id).to eq 'a'
	end
end
describe AuRec do
	let(:rec){AuRec.new(1, 'a', [])}
	it_behaves_like 'a record', AuRec.new('1', 'q')
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
	context 'aurec' do
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

		it "builds correctly references for both sides" do
			rec = parser.find_by_id('oid2')
			expect(rec.refs_to).to match_array ['oid1', 'oid4']
			expect(rec.refs_from).to match_array ['oid3']
			expect{|b| parser.from_references(&b)}.to yield_control.exactly(3).times
		end

		context '#find' do

			it "returns an array" do
				expect(parser.find(1)).to be_an Array
			end
			it "can take one identifier as argument" do
				rec = parser.find_by_id('oid1')
				expect(parser.find('oid1')).to eq [rec]
			end

			it "can take many identifiers as argument" do
				rec1 = parser.find_by_id( 'oid1' )
				rec2 = parser.find_by_id( 'oid4' )
        expect(parser.find('oid1', 'oid4')).to match_array [rec1, rec2]
			end
		end
	end

	context 'bibrec' do
		let(:parser){JsonDb.build(bib_sample)}

		it "reads correctly the number of records" do
			parser
			expect(JsonDb.count).to eq 3
		end

		it "returns nil when a record can't be found" do
			rec = parser.find_by_id('kaka')
			expect(rec).to be_nil
		end

		it "finds returns a record by when searching by its id" do
			rec = parser.find_by_id("oid1")
			expect(rec).to be_an BibRec
		end
	end

	context 'references' do
		let(:parser){JsonDb.build(bib_sample)}
		let(:rec_refs){parser.find_by_id('oid3')}

		it "detects the references" do
			expect(rec_refs.tags.empty?).to be_falsey
		end
		it "knows the right tags count" do
			expect(rec_refs.tags.length).to eq 2
		end

		it "knows the tag identifiers" do
			expect(rec_refs.tags.keys).to eq ['300', '400']
		end
		it 'returns the record ids for each tag identifier' do
			expect(rec_refs.tags['300']).to eq ['3234']
			expect(rec_refs.tags['400']).to eq ['4234', '4235']
		end

	end

end
