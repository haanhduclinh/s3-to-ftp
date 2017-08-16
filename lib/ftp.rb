class Ftp
  %i[host username password port current_path].each do |attribute|
    attr_accessor attribute
  end

  TYPE_FOLDER = 1
  TYPE_FILE = 2

  BACK = '.'.freeze
  LEVEL_UP = '..'.freeze

  def initialize(host:, username:, password:, port: 21)
    @current_path = '.'
    @host = host
    @username = username
    @password = password
    @port = 21

    yield(self) if block_given?
    @ftp = Net::FTP.new
    @ftp.connect(host, port)
    @ftp.login(username, password)
  end

  def create_directory(dirname)
    @ftp.mkdir(dirname)
  end

  def change_remote_path(path)
    @current_path = File.join(@current_path, path)
    @ftp.chdir(path)
  end

  def put(local_file_path)
    # sample './tmp/abc/level2/sample.jpg'
    # after remove. It will be './abc/level2/sample.jpg'
    server_path = local_file_path.sub('/tmp', '')

    create_dirs_and_change_remote(server_path)

    @ftp.put(local_file_path)
    reset_current_path
  end

  def create_dirs_and_change_remote(local_file_path)
    local_path = File.dirname(local_file_path)
    server_dirname = local_path.sub('./', '')
    file_path = '.'
    server_dirname.split('/').each do |dir|
      file_path << '/' + dir
      create_directory(dir) unless exist?(dir, keep_current_path: true)

      change_remote_path(file_path.split('/').last)
    end
  end

  def exist?(file_path, keep_current_path: false)
    dir_name = File.dirname(file_path)
    filename = File.basename(file_path)

    change_remote_path(dir_name) if parent_folder?(dir_name) || sub_folder?(dir_name)

    response = parse_from_ftp_info(all, fields: %w[filename])
    reset_current_path unless keep_current_path
    response.any? { |data| data[:filename] == filename }
  end

  def delete(file_path)
    dir_path = File.dirname(file_path)
    filename = File.basename(file_path)
    change_remote_path(dir_path)
    response = @ftp.delete(filename)
    reset_current_path
    response
  end

  def all
    @ftp.list
  end

  def size
    all.size
  end

  def list_all(type: nil)
    return_fields = %w[type filename]
    results = parse_from_ftp_info(all, fields: return_fields)

    lists = case type
            when :folder
              results.map.select do |data|
                data[:type] == TYPE_FOLDER
              end
            when :file
              results.map.select do |data|
                data[:type] == TYPE_FILE
              end
            else
              results
            end

    lists.map do |data|
      data[:filename]
    end.compact
  end

  private

  def reset_current_path
    str = ''
    @current_path.count('/').times { str << '../' }
    @current_path = '.'
    @ftp.chdir(str)
  end

  def parent_folder?(path)
    path.count('/').positive?
  end

  def sub_folder?(path)
    path.count('/') > 1
  end

  def file_type(ftp_type, filename)
    if ftp_type =~ /\d/ || File.basename(filename).include?('.') == false
      TYPE_FOLDER
    else
      TYPE_FILE
    end
  end

  def parse_from_ftp_info(response_array, fields: [])
    response_array.map do |ftp_infor|
      role, _n, owner, type, permission, _m, _d, _h, filename = ftp_infor.split
      {
        permission: permission,
        role: role,
        owner: owner,
        type: file_type(type, filename),
        filename: filename
      }.keep_if do |key, value|
        fields.include?(key.to_s) && value != BACK && value != LEVEL_UP
      end
    end
  end
end
