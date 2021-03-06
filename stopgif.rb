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

      ## example

      animation gif url: http://upload.wikimedia.org/wikipedia/commons/6/6a/Sorting_quicksort_anim.gif

          http://stopgif.herokuapp.com/?url=http%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2F6%2F6a%2FSorting_quicksort_anim.gif

      specify scene index.

          http://stopgif.herokuapp.com/?url=http%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2F6%2F6a%2FSorting_quicksort_anim.gif&index=20

      ## source

      https://github.com/swdyh/stopgif

    EOS
  end
end
