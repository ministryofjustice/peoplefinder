class Report < ActiveRecord::Base

  def to_csv_file
    file = File.open(tmp_file_path, 'w')
    file.puts content
    file.close
    file.path
  end

  def client_filename
    "#{name}_#{updated_at.strftime('%d-%m-%Y-%H-%M-%S')}.csv"
  end

  private

  def tmp_dir
    @tmp_dir ||= Rails.root.join('tmp', 'reports')
  end

  def tmp_file_name
    name + '.' + extension
  end

  def tmp_file_path
    FileUtils.mkdir_p tmp_dir
    @tmp_file_path ||= tmp_dir.join(tmp_file_name)
  end

end
