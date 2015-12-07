require 'spec_helper'
shared_context :sharable do
  let(:json_data){File.open(File.join(File.dirname(__FILE__), 'support', 'au_map.json' )).read}
  let(:sample){File.open(File.join(File.dirname(__FILE__), 'support', 'sample.json' )).read}
  let(:bib_sample){File.open(File.join(File.dirname(__FILE__), 'support', 'bib_sample.json' )).read}
end
