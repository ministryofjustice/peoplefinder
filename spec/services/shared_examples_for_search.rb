shared_examples 'a search' do
    let(:observer) { SearchResults.new }

    it 'returns the supplied search results instance' do
      expect(described_class.new(nil, observer).__send__(:perform_search))
        .to be observer
    end

    it 'returns empty result set and false when query is blank' do
      results = described_class.new('', observer).__send__(:perform_search)
      expect(results.set).to be_empty
      expect(results.contains_exact_match).to be false
    end

    it 'populates results' do
      expect(observer).to receive(:set=)
      described_class.new('test', observer).perform_search
    end

    it 'populates exact match flag' do
      expect(observer).to receive(:contains_exact_match=)
      described_class.new('test', observer).perform_search
    end
end