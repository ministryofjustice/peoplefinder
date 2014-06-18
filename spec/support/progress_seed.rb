def progress_seed
  let!(:accepted) { create(:progress, name: Progress.ALLOCATED_ACCEPTED) }
  let!(:pending) { create(:progress, name: Progress.ALLOCATED_PENDING) }
  let!(:unallocated) { create(:progress, name: Progress.UNALLOCATED) }
end 