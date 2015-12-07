require 'spec_helper'
shared_examples_for "a record" do |rec|
	it "responds_to id" do
		expect(rec).to respond_to :id
	end
	it "responds to old_id" do
		expect(rec).to respond_to :old_id
	end
end
