require 'fileutils'
require 'open-uri'
require 'digest/md5'

require 'RMagick'
require 'sinatra'

CACHE_DIR = '/tmp/stopgif'
FileUtils.mkdir_p CACHE_DIR

get '/' do
  if params[:url]
    url = params[:url]
    digest = Digest::MD5.hexdigest url
    path = File.join(CACHE_DIR, digest)

    begin
      unless File.exists? path
        open(path, 'w') { |f| f.write OpenURI.open_uri(url).read }
      end
      il = Magick::ImageList.new path
      r = il[params[:index] ? params[:index].to_i : 0]
      if r
        content_type r.mime_type
        r.to_blob
      else
        raise 'no image'
      end
    rescue Exception => e
      p ['Err', e.message, url, Time.now]
      # content_type 'text/plain'
      # halt 500, 'Error: ' + e.message
      redirect url
    end
  else
    content_type 'text/plain'
    "usage: /?url=xxxx"
  end
end
