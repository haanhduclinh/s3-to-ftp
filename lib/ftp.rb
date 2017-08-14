class Ftp
  %i[host username password port all].each do |attribute|
    attr_accessor attribute
  end

  TYPE_FOLDER = 1
  TYPE_FILE = 2

  def initialize(host:, username:, password:, port: 21)
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
    @ftp.chdir(path)
  end

  def put(local_file_path)
    @ftp.put(local_file_path)
  end

  def exist?(filename)
    response = parse_from_ftp_info(all, fields: %w[filename])
    response.any? { |data| data[:filename] == filename }
  end

  def all
    @all = @ftp.list('.')
  end

  def size
    @all ? @all.size : 0
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

  def file_type(ftp_type)
    if ftp_type =~ /\d/
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
        type: file_type(type),
        filename: filename
      }.keep_if { |key, _value| fields.include?(key.to_s) }
    end
  end
end
