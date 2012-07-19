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
      redirect(params[:alt] || url)
    end
  else
    content_type 'text/plain'
    s = <<-EOS
      # Stopgif

      extract a gif image from animation gif

          /?url=http%3A%2F%2Fexample.com%2Ffoo.gif

     ## options

          /?url=http%3A%2F%2Fexample.com%2Ffoo.gif&index=5
          /?url=http%3A%2F%2Fexample.com%2Ffoo.gif&alt=http%3A%2F%2Fexample.com%2Fbar.gif

      https://github.com/swdyh/stopgif

    EOS
  end
end
