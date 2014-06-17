def progress_seed
  let!(:accepted) { create(:progress, name: 'Allocated Accepted') }
  let!(:pending) { create(:progress, name: 'Allocated Pending') }
  let!(:unallocated) { create(:progress, name: 'Unallocated') }
end